//
//  RouteImageModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import AVFoundation
import SwiftUI


final class RouteImageModel: ObservableObject {
    let camera = Camera()
    @Published var viewfinderImage: Image?
    
    private var processedSamples: ProcessedSamplesSwift? = nil;
    
    
    init() {
        let samplesToProcess = ImportSamplesSwift(samples: [
            Sample(route: UIImage.init(named: "TestingSamples/r1")!, path: UIImage.init(named: "TestingSamples/r1_path")!, routeId: 1),
            Sample(route: UIImage.init(named: "TestingSamples/r2")!, path: UIImage.init(named: "TestingSamples/r2_path")!, routeId: 2),
            Sample(route: UIImage.init(named: "TestingSamples/r3")!, path: UIImage.init(named: "TestingSamples/r3_path")!, routeId: 3),
            Sample(route: UIImage.init(named: "TestingSamples/r4")!, path: UIImage.init(named: "TestingSamples/r4_path")!, routeId: 4),
            Sample(route: UIImage.init(named: "TestingSamples/r5")!, path: UIImage.init(named: "TestingSamples/r5_path")!, routeId: 5)
        ])
    
        
        processedSamples = OpenCVWrapper.processInputSamples(samplesToProcess)
        
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0 }
        
        let context = CIContext();

        for await image in imageStream {
            Task { @MainActor in
                let cgImage = context.createCGImage(image, from: image.extent)!;
                let uiImage = UIImage.init(cgImage: cgImage);
                // let grayImage = OpenCVWrapper.grayscaleImg(UIImage.init(cgImage: cgImage));
                // let analyzedImage = OpenCVWrapper.detectRoutesAndAddOverlay(processedSamples!, inputFrame: uiImage);
                let image = Image(uiImage: OpenCVWrapper.detectRoutesAndAddOverlay(processedSamples!, inputFrame: uiImage))
                viewfinderImage = image;
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
