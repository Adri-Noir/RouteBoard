//
//  RouteImageModel.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import AVFoundation
import GeneratedClient
import SwiftUI

@MainActor
final class RouteImageModel: ObservableObject {
  @Published var viewfinderImage: Image?
  @Published var closestRouteId: String? = nil

  @Published var detectedRoute: RouteDetails? = nil
  @Published var detectedDownloadedRoute: DownloadedRoute? = nil

  var allRoutes: [RouteDetails] = []
  var allDownloadedRoutes: [DownloadedRoute] = []

  private var routeIdToRoute: [String: RouteDetails] = [:]
  private var downloadedRouteIdToRoute: [String: DownloadedRoute] = [:]

  var routeDetectionLOD: RouteDetectionLOD = .medium

  var processInputSamples = ProcessInputSamples(samples: DetectInputSamples(samples: []))
  let camera = CameraModel(shouldDelegatePreview: true)

  init() {}

  init(
    routeSamples: [DetectSample], routeDetectionLOD: RouteDetectionLOD,
    allRoutes: [RouteDetails] = [], allDownloadedRoutes: [DownloadedRoute] = []
  ) {
    processInputSamples = ProcessInputSamples(samples: DetectInputSamples(samples: routeSamples))
    camera.isPreviewPaused = true
    self.routeDetectionLOD = routeDetectionLOD
    self.allRoutes = allRoutes
    self.allDownloadedRoutes = allDownloadedRoutes
    Task {
      await handleCameraPreviewsProcessEveryFrame()
    }
  }

  func handleCameraPreviewsProcessEveryFrame() async {
    let imageStream = camera.previewStream
      .map { $0 }

    for await image in imageStream {
      Task {
        let processedImage = processInputSamples.detectRoutesAndAddOverlay(
          inputFrame: image, options: DetectOptions(routeDetectionLOD: routeDetectionLOD))
        self.viewfinderImage = Image(uiImage: processedImage.frame)
        self.closestRouteId = processedImage.routeId

        let detectedId = processedImage.routeId
        if let foundRoute = routeIdToRoute[detectedId] {
          self.detectedRoute = foundRoute
          self.detectedDownloadedRoute = nil
        } else if let foundDownloadedRoute = downloadedRouteIdToRoute[detectedId] {
          self.detectedDownloadedRoute = foundDownloadedRoute
          self.detectedRoute = nil
        } else {
          self.detectedRoute = nil
          self.detectedDownloadedRoute = nil
        }
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

  func pauseCameraPreviews() {
    camera.isPreviewPaused = true
  }

  func resumeCameraPreviews(routeDetectionLOD: RouteDetectionLOD) {
    camera.isPreviewPaused = false
    self.routeDetectionLOD = routeDetectionLOD
  }

  func processSamples(samples: [DetectSample], routeDetectionLOD: RouteDetectionLOD) {
    processInputSamples = ProcessInputSamples(
      samples: DetectInputSamples(samples: samples), routeDetectionLOD: routeDetectionLOD)
  }

  func setAvailableRoutes(routes: [RouteDetails], downloadedRoutes: [DownloadedRoute]) {
    self.allRoutes = routes
    self.allDownloadedRoutes = downloadedRoutes
    self.routeIdToRoute = Dictionary(
      uniqueKeysWithValues: routes.compactMap { route in
        return (route.id, route)
      })
    self.downloadedRouteIdToRoute = Dictionary(
      uniqueKeysWithValues: downloadedRoutes.compactMap { route in
        guard let id = route.id else { return nil }
        return (id, route)
      })
  }

  func takePhotoAndDetectRoute(routeDetectionLOD: RouteDetectionLOD) async -> UIImage? {
    guard let uiImage = await camera.takePhoto() else { return nil }

    let processed = processInputSamples.detectRoutesAndAddOverlay(
      inputFrame: uiImage,
      options: DetectOptions(
        shouldAddFrameToOutput: true,
        routeDetectionLOD: routeDetectionLOD
      )
    )

    // Update the detected route properties
    let detectedId = processed.routeId
    self.closestRouteId = detectedId

    if let foundRoute = routeIdToRoute[detectedId] {
      self.detectedRoute = foundRoute
      self.detectedDownloadedRoute = nil
    } else if let foundDownloadedRoute = downloadedRouteIdToRoute[detectedId] {
      self.detectedDownloadedRoute = foundDownloadedRoute
      self.detectedRoute = nil
    } else {
      self.detectedRoute = nil
      self.detectedDownloadedRoute = nil
    }

    return processed.frame
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
