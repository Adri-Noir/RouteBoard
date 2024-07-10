//
//  RouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import AVFoundation
import SwiftUI


final class RouteImageModel: ObservableObject {
    @Published var viewfinderImage: Image?
    @Published var closestRouteId: Int? = nil;
    
    let camera = Camera(cameraSetting: .videoTaking)
    
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
            DispatchQueue.global(qos: .userInteractive).async {
                
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    let uiImage = UIImage(cgImage: cgImage)

                    let overlayAndRouteId = OpenCVWrapper.detectRoutesAndAddOverlay(self.processedSamples!, inputFrame: uiImage)
                    
                    let processedImage = OpenCVWrapper.addOverlay(toFrame: uiImage, overlay: overlayAndRouteId.overlay)
                    DispatchQueue.main.async {
                        self.viewfinderImage = Image(uiImage: processedImage)
                        self.closestRouteId = overlayAndRouteId.routeId == -1 ? nil : Int(overlayAndRouteId.routeId)
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

                    DispatchQueue.main.async {
                        let overlayAndRouteId = OpenCVWrapper.detectRoutesAndAddOverlay(self.processedSamples!, inputFrame: uiImage)
                        let processedImage = OpenCVWrapper.addOverlay(toFrame: uiImage, overlay: overlayAndRouteId.overlay)
                        self.viewfinderImage = Image(uiImage: processedImage)
                        self.closestRouteId = overlayAndRouteId.routeId == -1 ? nil : Int(overlayAndRouteId.routeId)
                    }
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
