//
//  RouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import AVFoundation
import SwiftUI


final class RouteImageModel: ObservableObject {
    let camera = Camera(cameraSetting: .videoTaking)
    @Published var viewfinderImage: Image?
    private var savedOverlay: CVMap?
    private var frameCounter: Int = 0;
    
    private var processedSamples: ProcessedSamplesSwift? = nil;
    
    
    init() {
        let samplesToProcess = ImportSamplesSwift(samples: [
            Sample(route: UIImage.init(named: "TestingSamples/apaches")!, path: UIImage.init(named: "TestingSamples/apaches_path")!, routeId: 1),
            Sample(route: UIImage.init(named: "TestingSamples/flik")!, path: UIImage.init(named: "TestingSamples/flik_path")!, routeId: 2),
            Sample(route: UIImage.init(named: "TestingSamples/flok")!, path: UIImage.init(named: "TestingSamples/flok_path")!, routeId: 3),
            Sample(route: UIImage.init(named: "TestingSamples/frenky")!, path: UIImage.init(named: "TestingSamples/frenky_path")!, routeId: 4),
        ])

        processedSamples = OpenCVWrapper.processInputSamples(samplesToProcess)
        
        Task {
            await handleCameraPreviewsProcessEveryFrame()
        }
    }
    
    func handleCameraPreviewsProcessEveryFrame() async {
        let imageStream = camera.previewStream
            .map { $0 }
        
        let context = CIContext();

        for await image in imageStream {
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let uiImage = UIImage(cgImage: cgImage)

                    let overlay = OpenCVWrapper.detectRoutesAndAddOverlay(self.processedSamples!, inputFrame: uiImage)
                    
                    let processedImage = OpenCVWrapper.addOverlay(toFrame: uiImage, overlay: overlay)
                    DispatchQueue.main.async {
                        self.viewfinderImage = Image(uiImage: processedImage);
                    }
                }
                
            }
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0 }
        
        let context = CIContext();
        let skipFrameAnalysis = 3;

        for await image in imageStream {
            DispatchQueue.global(qos: .userInitiated).async {
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let uiImage = UIImage(cgImage: cgImage)

                    let overlay = self.savedOverlay ?? OpenCVWrapper.detectRoutesAndAddOverlay(self.processedSamples!, inputFrame: uiImage)
                    self.savedOverlay = overlay

                    
                    let processedImage = OpenCVWrapper.addOverlay(toFrame: uiImage, overlay: overlay)
                    DispatchQueue.main.async {
                        self.viewfinderImage = Image(uiImage: processedImage);
                    }
                    

                    if self.frameCounter % skipFrameAnalysis == 0 {
                        self.savedOverlay = nil
                    }

                    self.frameCounter = (self.frameCounter + 1) % skipFrameAnalysis;
                }
            }
        }
    }
}


fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}


fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
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
