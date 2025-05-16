//
//  RouteImageModel.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import AVFoundation
import SwiftUI

@MainActor
final class RouteImageModel: ObservableObject {
  @Published var viewfinderImage: Image?
  @Published var closestRouteId: Int? = nil

  var processInputSamples = ProcessInputSamples(samples: DetectInputSamples(samples: []))
  let camera = CameraModel(shouldDelegatePreview: true)

  init() {}

  init(routeSamples: [DetectSample]) {
    processInputSamples = ProcessInputSamples(samples: DetectInputSamples(samples: routeSamples))
    Task {
      await handleCameraPreviewsProcessEveryFrame()
    }
  }

  func handleCameraPreviewsProcessEveryFrame() async {
    let imageStream = camera.previewStream
      .map { $0 }

    for await image in imageStream {
      Task {
        let processedImage = processInputSamples.detectRoutesAndAddOverlay(inputFrame: image)
        self.viewfinderImage = Image(uiImage: processedImage.frame)
        self.closestRouteId = Int(processedImage.routeId)
      }
    }
  }

  func startCamera() async {
    do {
      try await camera.start()
    } catch {
      print("Error starting camera: \(error)")
    }
  }

  func stopCamera() async {
    camera.stop()
  }

  func processSamples(samples: [DetectSample], routeDetectionLOD: RouteDetectionLOD) {
    processInputSamples = ProcessInputSamples(
      samples: DetectInputSamples(samples: samples), routeDetectionLOD: routeDetectionLOD)
  }
}

extension Image.Orientation {

  fileprivate init(_ cgImageOrientation: CGImagePropertyOrientation) {
    switch cgImageOrientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}
