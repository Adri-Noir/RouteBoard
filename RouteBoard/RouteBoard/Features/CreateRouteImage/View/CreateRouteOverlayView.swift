//
//  CreateRouteOverlayView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import SwiftUI
import opencv2

struct CreateRouteOverlayView<Content: View>: View {
    @ObservedObject var createRouteImageModel: CreateRouteImageModel
    @ViewBuilder var content: Content
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if createRouteImageModel.isShowingTakenPhoto()  {
                createRouteImageModel.photoImage?
                    .resizable()
                    .opacity(0.5)
            } else {
                content
            }
            
            
            if createRouteImageModel.isShowingTakenPhoto() {
                if createRouteImageModel.isEditingPhoto() {
                    PhotoEditingOverlayView(createRouteImageModel: createRouteImageModel)
                } else {
                    ConfirmPhotoOverlayView(createRouteImageModel: createRouteImageModel)
                }
            } else {
                PhotoTakingOverlayView(createRouteImageModel: createRouteImageModel)
            }
        }
    }
}

extension UIImage {
    func rotateImage90Degrees() -> UIImage? {
        let size = self.size
        UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.height / 2, y: size.width / 2)
        context.rotate(by: .pi / 2)
        self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
