//
//  CreateRouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import AVFoundation
import SwiftUI

@MainActor
final class CreateRouteImageModel: ObservableObject {
    @State private var camera = CameraModel(cameraSetting: .photoTaking)
    @Published var viewfinderImage: Image?
    @Published var photoImage: Image?
    @Published var isShowingPhoto: Bool = false
    
    init() {
        Task {
            await camera.start()
        }
        
        Task {
            await self.runViewfinder()
        }
    }
    
    func getPreviewSource() -> PreviewSource {
        return camera.previewSource
    }
    
    func takePhoto() async {
        self.photoImage = await camera.takePhoto()
        pauseViewFinder()
    }
    
    func pauseViewFinder() {
        camera.isPreviewPaused = true
        isShowingPhoto = true
    }
    
    func resumeViewFinder() {
        camera.isPreviewPaused = false
        isShowingPhoto = false
    }
    
    func runViewfinder() async {
        let imageStream = camera.previewStream
            .map { $0 }
        
        let context = CIContext();

        for await image in imageStream {
            Task {
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let uiImage = UIImage(cgImage: cgImage)

                    self.viewfinderImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
