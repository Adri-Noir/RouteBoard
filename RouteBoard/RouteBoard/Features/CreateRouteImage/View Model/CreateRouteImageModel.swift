//
//  CreateRouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import AVFoundation
import SwiftUI


final class CreateRouteImageModel: ObservableObject {
    let camera = Camera(cameraSetting: .photoTaking)
    @Published var viewfinderImage: Image?
    @Published var photoImage: Image?
    @Published var isShowingPhoto: Bool = false
    
    init() {
        Task {
            await runPhotoStream()
        }
        
        Task {
            await runViewfinder()
        }
    }
    
    func pauseViewFinder() {
        camera.isPreviewPaused = true
        isShowingPhoto = true
    }
    
    func resumeViewFinder() {
        camera.isPreviewPaused = false
        isShowingPhoto = false
    }
    
    func runPhotoStream() async {
        let imageStream = camera.photoStream
            .map { $0 }
        
        for await image in imageStream {
            let cgImage = image.cgImageRepresentation()!
            let uiImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                self.pauseViewFinder()
                self.photoImage = Image(uiImage: uiImage);
            }
            
        }
    }
    
    func runViewfinder() async {
        let imageStream = camera.previewStream
            .map { $0 }
        
        let context = CIContext();

        for await image in imageStream {
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let uiImage = UIImage(cgImage: cgImage)

                    DispatchQueue.main.async {
                        self.viewfinderImage = Image(uiImage: uiImage);
                    }
                }
                
            }
        }
    }
}
