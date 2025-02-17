//
//  ProcessInputSamples.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 18.12.2024..
//

import opencv2

class DetectSample {
  var route: UIImage
  var path: UIImage
  var routeId: String

  init(route: UIImage, path: UIImage, routeId: String) {
    self.route = route
    self.path = path
    self.routeId = routeId
  }
}

class DetectInputSamples {
  var samples: [DetectSample]

  init(samples: [DetectSample]) {
    self.samples = samples
  }
}

class DetectProcessedSample {
  var referenceKP: [opencv2.KeyPoint]
  var referenceDES: opencv2.Mat
  var routeReference: UIImage
  var routeId: String

  init(
    referenceKP: [opencv2.KeyPoint], referenceDES: opencv2.Mat, routeReference: UIImage,
    routeId: String
  ) {
    self.referenceKP = referenceKP
    self.referenceDES = referenceDES
    self.routeReference = routeReference
    self.routeId = routeId
  }
}

class DetectProcessedSamples {
  var samples: [DetectProcessedSample] = []

  init() {}

  init(samples: [DetectProcessedSample]) {
    self.samples = samples
  }

  func addSample(sample: DetectProcessedSample) {
    samples.append(sample)
  }
}

class DetectProcessedFrame {
  var frame: UIImage
  var routeId: String

  init(frame: UIImage, routeId: String) {
    self.frame = frame
    self.routeId = routeId
  }
}

class ProcessInputSamples {
  let DROP_INPUTFRAME_FACTOR: Double = 0.9
  let MAX_RESOLUTION_PX: Double = 1200.0
  let LOWES_RATIO_LAW: Float = 0.7
  let MIN_MATCH_COUNT: Int = 10
  let SHOULD_SHOW_THE_FIRST_VALID: Bool = true

  let sift = SIFT.create()
  let matcher = FlannBasedMatcher.create()
  let processedSamples = DetectProcessedSamples()

  init() {}

  init(samples: DetectInputSamples) {
    processInputSamples(samples: samples)
  }

  func processInputSamples(samples: DetectInputSamples) {
    sift.clear()
    matcher.clear()

    for sample in samples.samples {
      let routeImageMatrix = Mat(uiImage: sample.route)
      let resizedRouteImageMatrix = Mat()

      let pathImageMatrix = Mat(uiImage: sample.path)
      let resizedPathImageMatrix = Mat()

      let resizeFactor =
        Double(MAX_RESOLUTION_PX) / Double(max(routeImageMatrix.rows(), routeImageMatrix.cols()))

      Imgproc.resize(
        src: routeImageMatrix, dst: resizedRouteImageMatrix, dsize: Size(), fx: resizeFactor,
        fy: resizeFactor)
      Imgproc.resize(
        src: pathImageMatrix, dst: resizedPathImageMatrix, dsize: Size(), fx: resizeFactor,
        fy: resizeFactor)

      var routeKeypoints: [opencv2.KeyPoint] = []
      let routeDescriptors = Mat()

      sift.detectAndCompute(
        image: resizedRouteImageMatrix, mask: Mat(), keypoints: &routeKeypoints,
        descriptors: routeDescriptors)

      let keypointsCount = routeKeypoints.count

      if keypointsCount == 0 || routeDescriptors.empty() {
        NSLog("Keypoints or descriptors are empty for routeId: \(sample.routeId)")
        continue
      }

      let pathImage = resizedPathImageMatrix.toUIImage()

      processedSamples.addSample(
        sample: DetectProcessedSample(
          referenceKP: routeKeypoints, referenceDES: routeDescriptors, routeReference: pathImage,
          routeId: sample.routeId))
    }
  }

  func detectRoutesAndAddOverlay(inputFrame: UIImage) -> DetectProcessedFrame {
    sift.clear()

    let frameMatrix = Mat(uiImage: inputFrame)
    let frameRows = frameMatrix.rows()
    let frameCols = frameMatrix.cols()

    if frameMatrix.empty() {
      return DetectProcessedFrame(frame: inputFrame, routeId: "-1")
    }

    let resizedFrameMatrix = Mat(
      uiImage: inputFrame.scaleImage(
        toSize: CGSize(
          width: Double(frameMatrix.cols()) * DROP_INPUTFRAME_FACTOR,
          height: Double(frameMatrix.rows()) * DROP_INPUTFRAME_FACTOR))!)

    var frameOutput = Mat.zeros(
      frameRows, cols: frameCols, type: frameMatrix.type())

    var frameKeypoints: [opencv2.KeyPoint] = []
    let frameDescriptors = Mat()

    sift.detectAndCompute(
      image: resizedFrameMatrix, mask: Mat(), keypoints: &frameKeypoints,
      descriptors: frameDescriptors)

    if frameKeypoints.count < 3 || frameDescriptors.empty() {
      return DetectProcessedFrame(frame: frameOutput.toUIImage(), routeId: "")
    }

    var closestRouteId = ""

    for sample in processedSamples.samples {
      var knnMatches: [[DMatch]] = []
      matcher.knnMatch(
        queryDescriptors: sample.referenceDES, trainDescriptors: frameDescriptors,
        matches: &knnMatches, k: 2)

      var numberOfGoodPoints = 0
      var srcPts: [opencv2.Point2f] = []
      var dstPts: [opencv2.Point2f] = []

      for matchPair in knnMatches {
        if matchPair.count >= 2, matchPair[0].distance < LOWES_RATIO_LAW * matchPair[1].distance {
          numberOfGoodPoints += 1
          let queryIdx = matchPair[0].queryIdx
          let trainIdx = matchPair[0].trainIdx

          let srcPoint = sample.referenceKP[Int(queryIdx)].pt
          let dstPoint = frameKeypoints[Int(trainIdx)].pt

          srcPts.append(srcPoint)
          dstPts.append(dstPoint)
        }
      }

      // TODO: add code for adding only the first match and the best match

      if numberOfGoodPoints > MIN_MATCH_COUNT {
        let srcMat = MatOfPoint2f(array: srcPts)
        let dstMat = MatOfPoint2f(array: dstPts)

        let homography = Calib3d.findHomography(
          srcPoints: srcMat, dstPoints: dstMat, method: Calib3d.RANSAC, ransacReprojThreshold: 3.0)

        if !homography.empty(), homography.rows() == 3, homography.cols() == 3 {
          // let routeMatrix = Mat(uiImage: sample.routeReference)
          continue

          guard let metalHomography = ImageTransformations.convertOpenCVMatToFloat3x3(homography)
          else {
            continue
          }

          guard
            let warppedImage = ImageTransformations.warpImage(
              image: sample.routeReference,
              homography: metalHomography,
              outputSize: CGSize(width: Int(frameCols), height: Int(frameRows))
            )
          else {
            continue
          }

          frameOutput = Mat(uiImage: warppedImage)
          Core.addWeighted(
            src1: frameMatrix, alpha: 1.0, src2: frameOutput, beta: 1.0, gamma: 0.0,
            dst: frameOutput)
          return DetectProcessedFrame(frame: frameOutput.toUIImage(), routeId: closestRouteId)
        }
      }
    }

    // Imgproc.resize(
    //   src: frameOutput, dst: frameOutput,
    //   dsize: Size(width: frameMatrix.cols(), height: frameMatrix.rows()))

    // Core.addWeighted(
    //   src1: frameMatrix, alpha: 1.0, src2: frameOutput, beta: 1.0, gamma: 0.0, dst: frameOutput)

    return DetectProcessedFrame(frame: inputFrame, routeId: "-1")
  }
}

extension UIImage {
  func scaleImage(toSize newSize: CGSize) -> UIImage? {
    // Ensure the new size has valid dimensions
    guard newSize.width > 0, newSize.height > 0 else { return nil }

    // Create a bitmap context with the exact new size
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    guard
      let context = CGContext(
        data: nil,
        width: Int(newSize.width),
        height: Int(newSize.height),
        bitsPerComponent: 8,
        bytesPerRow: Int(newSize.width) * 4,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
      )
    else { return nil }

    // Set the interpolation quality to high
    context.interpolationQuality = .high

    // Flip the context to match UIKit's coordinate system
    context.translateBy(x: 0, y: newSize.height)
    context.scaleBy(x: 1, y: -1)

    // Draw the original image into the context, scaling it to the new size
    guard let cgImage = self.cgImage else { return nil }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))

    // Create a new CGImage from the context
    guard let scaledCGImage = context.makeImage() else { return nil }

    // Convert the CGImage back to UIImage
    let scaledUIImage = UIImage(cgImage: scaledCGImage)

    return scaledUIImage
  }
}
