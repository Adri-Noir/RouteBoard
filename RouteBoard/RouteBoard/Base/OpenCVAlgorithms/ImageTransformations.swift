//
//  ImageTransformations.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.02.2025..
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import Metal
import MetalKit
import UIKit
import opencv2

class ImageTransformations {
  static let device = MTLCreateSystemDefaultDevice()!
  static let commandQueue = device.makeCommandQueue()!
  static let textureLoader = MTKTextureLoader(device: device)

  init() {}

  static func convertOpenCVMatToFloat3x3(_ mat: Mat) -> double3x3? {
    guard mat.rows() == 3 && mat.cols() == 3 else {
      print("Error: Input Mat must be a 3x3 matrix.")
      return nil
    }
    var result = double3x3()

    for row in 0..<3 {
      for col in 0..<3 {
        result[row][col] = Double(mat.at<Double>(row: Int32(row), col: Int32(col)).v as Double)
      }
    }

    return result
  }

  static func warpImage(
    image: UIImage,
    homography: double3x3,
    outputSize: CGSize
  ) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }

    let imageSize = ciImage.extent.size

    // Define the corners of the image
    let topLeft = CGPoint(x: 0, y: 0)
    let topRight = CGPoint(x: imageSize.width, y: 0)
    let bottomLeft = CGPoint(x: 0, y: imageSize.height)
    let bottomRight = CGPoint(x: imageSize.width, y: imageSize.height)

    // Apply the homography to the corners
    let transformedTopLeft = applyHomography(homography, to: topLeft)
    let transformedTopRight = applyHomography(homography, to: topRight)
    let transformedBottomLeft = applyHomography(homography, to: bottomLeft)
    let transformedBottomRight = applyHomography(homography, to: bottomRight)

    // Convert transformed points to CIVector
    let topLeftVector = CIVector(cgPoint: transformedTopLeft)
    let topRightVector = CIVector(cgPoint: transformedTopRight)
    let bottomLeftVector = CIVector(cgPoint: transformedBottomLeft)
    let bottomRightVector = CIVector(cgPoint: transformedBottomRight)

    // Create the perspective transform filter
    let perspectiveTransformFilter = CIFilter(name: "CIPerspectiveTransform")!
    perspectiveTransformFilter.setValue(topLeftVector, forKey: "inputTopLeft")
    perspectiveTransformFilter.setValue(topRightVector, forKey: "inputTopRight")
    perspectiveTransformFilter.setValue(bottomRightVector, forKey: "inputBottomRight")
    perspectiveTransformFilter.setValue(bottomLeftVector, forKey: "inputBottomLeft")
    perspectiveTransformFilter.setValue(ciImage, forKey: kCIInputImageKey)

    // Get the output image from the perspective transform
    guard let perspectiveOutputCIImage = perspectiveTransformFilter.outputImage else { return nil }

    // Calculate the scale factors for width and height
    let scaleX = outputSize.width / perspectiveOutputCIImage.extent.width
    let scaleY = outputSize.height / perspectiveOutputCIImage.extent.height

    // Apply scaling to the output image
    let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
    let scaledOutputCIImage = perspectiveOutputCIImage.transformed(by: scaleTransform).cropped(
      to: CGRect(origin: .zero, size: outputSize))

    // Convert CIImage to UIImage
    if let device = MTLCreateSystemDefaultDevice() {
      let gpuContext = CIContext(mtlDevice: device)
      guard
        let cgImage = gpuContext.createCGImage(
          scaledOutputCIImage, from: scaledOutputCIImage.extent)
      else { return nil }
      let outputUIImage = UIImage(cgImage: cgImage)

      return outputUIImage
    }

    return nil
  }

  static func applyHomography(_ homography: double3x3, to point: CGPoint) -> CGPoint {
    let x = point.x
    let y = point.y

    // Apply the homography transformation
    let denominator = homography[2, 0] * x + homography[2, 1] * y + homography[2, 2]
    let transformedX =
      (homography[0, 0] * x + homography[0, 1] * y + homography[0, 2]) / denominator
    let transformedY =
      (homography[1, 0] * x + homography[1, 1] * y + homography[1, 2]) / denominator

    return CGPoint(x: transformedX, y: transformedY)
  }

  static func transformPoints(points: [SIMD2<Float>], matrix: float3x3) -> [SIMD2<Float>] {
    let bufferPoints = device.makeBuffer(
      bytes: points, length: MemoryLayout<SIMD2<Float>>.stride * points.count)
    let bufferMatrix = device.makeBuffer(bytes: [matrix], length: MemoryLayout<float3x3>.stride)
    let bufferResult = device.makeBuffer(length: MemoryLayout<SIMD2<Float>>.stride * points.count)

    let commandBuffer = commandQueue.makeCommandBuffer()!
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()!

    let computeFunction = device.makeDefaultLibrary()!.makeFunction(name: "perspective_transform")!
    let pipelineState = try! device.makeComputePipelineState(function: computeFunction)

    commandEncoder.setComputePipelineState(pipelineState)
    commandEncoder.setBuffer(bufferPoints, offset: 0, index: 0)
    commandEncoder.setBuffer(bufferMatrix, offset: 0, index: 1)
    commandEncoder.setBuffer(bufferResult, offset: 0, index: 2)

    let threadsPerGrid = MTLSize(width: points.count, height: 1, depth: 1)
    let threadsPerThreadgroup = MTLSize(
      width: pipelineState.maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
    commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

    commandEncoder.endEncoding()
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()

    let buffer = bufferResult!.contents().bindMemory(to: SIMD2<Float>.self, capacity: points.count)

    return Array(UnsafeBufferPointer(start: buffer, count: points.count))
  }
}

extension MTLTexture {
  func toUIImage() -> UIImage? {
    guard self.pixelFormat == .rgba8Unorm else {
      print("Unsupported pixel format")
      return nil
    }

    let width = self.width
    let height = self.height
    let rowBytes = self.width * 4
    let bufferSize = width * height * 4

    var bytes = [UInt8](repeating: 0, count: bufferSize)
    self.getBytes(
      &bytes, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(
      rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
    )

    guard
      let context = CGContext(
        data: &bytes,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: rowBytes,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
      ), let cgImage = context.makeImage()
    else {
      return nil
    }

    return UIImage(cgImage: cgImage)
  }
}
