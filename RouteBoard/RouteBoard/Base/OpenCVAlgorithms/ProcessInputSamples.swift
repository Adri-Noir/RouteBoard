//
//  ProcessInputSamples.swift
//  RouteBoard
//
//  Created with <3 on 18.12.2024..
//

import UIKit
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

struct DetectOptions {
  var shouldAddFrameToOutput: Bool = false
  var routeDetectionLOD: RouteDetectionLOD = .medium
}

class ProcessInputSamples {
  let LOWES_RATIO_LAW: Float = 0.7
  let MIN_MATCH_COUNT: Int = 10

  let sift = SIFT.create()
  let matcher = FlannBasedMatcher.create()
  var processedSamples = DetectProcessedSamples()

  init() {}

  init(samples: DetectInputSamples, routeDetectionLOD: RouteDetectionLOD = .medium) {
    processInputSamples(samples: samples, routeDetectionLOD: routeDetectionLOD)
  }

  func processInputSamples(
    samples: DetectInputSamples, routeDetectionLOD: RouteDetectionLOD = .medium
  ) {
    sift.clear()
    matcher.clear()
    processedSamples = DetectProcessedSamples()

    for sample in samples.samples {
      let routeImageMatrix = Mat(uiImage: sample.route)
      let resizedRouteImageMatrix = Mat()

      let maxResolutionPx = min(
        routeDetectionLOD == .low ? 600 : routeDetectionLOD == .medium ? 1000 : 1600,
        max(routeImageMatrix.rows(), routeImageMatrix.cols()))

      let resizeFactor =
        Double(maxResolutionPx) / Double(max(routeImageMatrix.rows(), routeImageMatrix.cols()))

      Imgproc.resize(
        src: routeImageMatrix, dst: resizedRouteImageMatrix, dsize: Size(), fx: resizeFactor,
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

      let originalPath = sample.path
      let newSize = CGSize(
        width: originalPath.size.width * CGFloat(resizeFactor),
        height: originalPath.size.height * CGFloat(resizeFactor))
      UIGraphicsBeginImageContextWithOptions(newSize, false, originalPath.scale)
      originalPath.draw(in: CGRect(origin: .zero, size: newSize))
      let pathImage = UIGraphicsGetImageFromCurrentImageContext() ?? originalPath
      UIGraphicsEndImageContext()

      processedSamples.addSample(
        sample: DetectProcessedSample(
          referenceKP: routeKeypoints, referenceDES: routeDescriptors, routeReference: pathImage,
          routeId: sample.routeId))
    }
  }

  func detectRoutesAndAddOverlay(inputFrame: UIImage, options: DetectOptions = DetectOptions())
    -> DetectProcessedFrame
  {
    sift.clear()

    let frameMatrix = Mat(uiImage: inputFrame)

    if frameMatrix.empty() {
      return DetectProcessedFrame(frame: inputFrame, routeId: "-1")
    }

    let dropInputFrameFactor =
      options.routeDetectionLOD == .low ? 0.5 : options.routeDetectionLOD == .medium ? 0.75 : 0.9

    let resizedFrameMatrix = Mat()
    Imgproc.resize(
      src: frameMatrix, dst: resizedFrameMatrix, dsize: Size(), fx: dropInputFrameFactor,
      fy: dropInputFrameFactor)

    let frameOutput = Mat.zeros(
      resizedFrameMatrix.rows(), cols: resizedFrameMatrix.cols(), type: resizedFrameMatrix.type())

    var frameKeypoints: [opencv2.KeyPoint] = []
    let frameDescriptors = Mat()

    sift.detectAndCompute(
      image: resizedFrameMatrix, mask: Mat(), keypoints: &frameKeypoints,
      descriptors: frameDescriptors)

    let frameRows = resizedFrameMatrix.rows()
    let frameCols = resizedFrameMatrix.cols()

    if frameKeypoints.count < 3 || frameDescriptors.empty() {
      return DetectProcessedFrame(frame: frameOutput.toUIImage(), routeId: "")
    }

    var minDistance = Double.greatestFiniteMagnitude
    var closestRouteId = ""
    var closestOverlay = Mat()

    let centerX = frameCols / 2
    let centerY = frameRows / 2
    let frameCenter = opencv2.Point2f(x: Float(centerX), y: Float(centerY))

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
          let transformedCenter = MatOfPoint2f(array: [frameCenter])
          let transformedResult = MatOfPoint2f()

          Core.perspectiveTransform(
            src: transformedCenter, dst: transformedResult, m: homography.inv())

          let routeMatrix = Mat(uiImage: sample.routeReference)
          let routeReferencePoint = opencv2.Point2f(
            x: Float(routeMatrix.cols()) / 2.0, y: Float(routeMatrix.rows()) / 2.0)
          let distance = Core.norm(
            src1: transformedResult, src2: MatOfPoint2f(array: [routeReferencePoint]))

          let overlay = Mat()
          Imgproc.warpPerspective(
            src: routeMatrix, dst: overlay, M: homography,
            dsize: Size(width: frameCols, height: frameRows))

          if distance < minDistance {
            minDistance = distance
            if !closestOverlay.empty() {
              Core.add(src1: frameOutput, src2: closestOverlay, dst: frameOutput)
            }
            closestOverlay = overlay
            closestRouteId = sample.routeId
          } else {
            Core.add(src1: frameOutput, src2: overlay, dst: frameOutput)
          }
        }
      }
    }

    if !closestOverlay.empty() {
      Core.add(src1: frameOutput, src2: closestOverlay, dst: frameOutput)
    }

    Imgproc.resize(
      src: frameOutput, dst: frameOutput,
      dsize: Size(width: frameMatrix.cols(), height: frameMatrix.rows()))
    if options.shouldAddFrameToOutput {
      Core.addWeighted(
        src1: frameMatrix, alpha: 1.0, src2: frameOutput, beta: 1.0, gamma: 0.0, dst: frameOutput)
    }

    return DetectProcessedFrame(frame: frameOutput.toUIImage(), routeId: closestRouteId)
  }
}
