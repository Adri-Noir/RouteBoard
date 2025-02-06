//
//  CreateRouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
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
    @Published var photoMatrix: Mat?
    @Published var imageCreatingState: PhotoCreatingState = .isShowingPreview
    @Published var canvasPoints: [CGPoint] = []
    @Published var pointsOnImage: [CGPoint] = []
    @Published var routeImage: Image?

    @Published var photoUIImage: UIImage?
    @Published var routeUIImage: UIImage?
    
    init() {
        Task {
            await camera.start()
        }
    }
    
    func getPreviewSource() -> PreviewSource {
        return camera.previewSource
    }
    
    func takePhoto() async {
        self.photoImage = await camera.takePhoto()
        let uiImage = ImageRenderer(content: self.photoImage).uiImage
        guard uiImage != nil else {
            return
        }
        self.photoMatrix = Mat(uiImage: uiImage!)
        imageCreatingState = .isShowingEditing
    }
    
    func isShowingTakenPhoto() -> Bool {
        return imageCreatingState == .isShowingPhoto || imageCreatingState == .isShowingEditing || imageCreatingState == .isCurrentlyDrawing
    }

    func isEditingPhoto() -> Bool {
        return imageCreatingState == .isShowingEditing || imageCreatingState == .isCurrentlyDrawing
    }
    
    func resetToPreview() {
        imageCreatingState = .isShowingPreview
        photoImage = nil
        photoMatrix = nil
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
    
    func createRouteImage() {
        let uiImage = ImageRenderer(content: self.photoImage).uiImage
        guard uiImage != nil else {
            return
        }
        let routeUIImage = CreateRouteImage.createRouteLineImage(points: pointsOnImage, picture: uiImage!)
        routeImage = Image(uiImage: routeUIImage)
        
        self.routeUIImage = routeUIImage
    }
}
