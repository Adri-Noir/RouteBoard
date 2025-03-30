//
//  CreateRouteImageModel.swift
//  RouteBoard
//
//  Created with <3 on 06.07.2024..
//

import AVFoundation
import SwiftUI
import opencv2

enum PhotoCreatingState {
  case isShowingPreview
  case isShowingEditing
  case isCurrentlyDrawing
  case isShowingPhoto
}

@MainActor
final class CreateRouteImageModel: ObservableObject {
  @State private var camera = CameraModel(cameraSetting: .photoTaking)
  @Published var viewfinderImage: Image?
  @Published var photoImage: Image?
  @Published var imageCreatingState: PhotoCreatingState = .isShowingPreview
  @Published var canvasPoints: [CGPoint] = []
  @Published var pointsOnImage: [CGPoint] = []
  @Published var routeImage: Image?
  @Published var combinedUIImage: Image?

  @Published var photoUIImage: UIImage?
  @Published var routeUIImage: UIImage?

  // MARK: - Route upload properties
  @Published var routeId: String?
  @Published var isUploading: Bool = false

  init() {
    #if !targetEnvironment(simulator)
      Task {
        await camera.start()
      }
    #endif
  }

  // MARK: - Set route ID
  func setRouteId(_ id: String) {
    self.routeId = id
  }

  func getPreviewSource() -> PreviewSource {
    return camera.previewSource
  }

  func takePhoto() async {
    #if targetEnvironment(simulator)
      // Use test image in simulator
      if let testImage = UIImage(named: "TestingSamples/limski/pikachu") {
        self.photoImage = Image(uiImage: testImage)
        self.photoUIImage = testImage
        imageCreatingState = .isShowingEditing
        return
      }
    #endif

    // Normal camera flow for physical devices
    self.photoImage = await camera.takePhoto()
    let uiImage = ImageRenderer(content: self.photoImage).uiImage
    guard let uiImage = uiImage else {
      return
    }

    self.photoUIImage = uiImage
    imageCreatingState = .isShowingEditing
  }

  var isShowingPreview: Bool {
    return imageCreatingState == .isShowingPreview
  }

  var isShowingTakenPhoto: Bool {
    return imageCreatingState == .isShowingPhoto
  }

  var isEditingPhoto: Bool {
    return imageCreatingState == .isShowingEditing || imageCreatingState == .isCurrentlyDrawing
  }

  func resetToPreview() {
    imageCreatingState = .isShowingPreview
    photoImage = nil
    canvasPoints.removeAll()
    pointsOnImage.removeAll()
  }

  func resetToEditing() {
    imageCreatingState = .isShowingEditing
    canvasPoints.removeAll()
    pointsOnImage.removeAll()
  }

  func addPointToCanvas(_ point: CGPoint) {
    canvasPoints.append(point)
  }

  func addPointToImage(_ point: CGPoint) {
    pointsOnImage.append(point)
  }

  func createRouteImageFromView<Content: View>(fromView view: Content) {
    guard let uiImage = ImageRenderer(content: self.photoImage).uiImage else {
      return
    }
    let routeUIImage = CreateRouteImage.createRouteLineImage(
      points: pointsOnImage, picture: uiImage)
    routeImage = Image(uiImage: routeUIImage)

    self.routeUIImage = routeUIImage

    guard let viewUiImage = ImageRenderer(content: view).uiImage else {
      return
    }

    self.combinedUIImage = Image(uiImage: viewUiImage)
  }

  // Keep the original method for backward compatibility
  func createRouteImage() {
    guard let uiImage = ImageRenderer(content: self.photoImage).uiImage else {
      return
    }
    let routeUIImage = CreateRouteImage.createRouteLineImage(
      points: pointsOnImage, picture: uiImage)
    self.routeUIImage = routeUIImage
    self.routeImage = Image(uiImage: routeUIImage)
  }
}
