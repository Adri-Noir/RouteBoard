//
//  CreateRouteOverlayView.swift
//  RouteBoard
//
//  Created with <3 on 06.07.2024..
//

import SwiftUI
import opencv2

struct CreateRouteOverlayView: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel

  @ViewBuilder
  func viewFromTwoImages(image1: Image, image2: Image) -> some View {
    ZStack {
      image1
      image2
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        PhotoDrawingCanvas(createRouteImageModel: createRouteImageModel)
          .gesture(
            DragGesture(minimumDistance: 1)
              .onChanged { value in
                createRouteImageModel.imageCreatingState = .isCurrentlyDrawing
                createRouteImageModel.addPointToCanvas(value.location)

                // Get dimensions from the actual photo UIImage
                let photoWidth: CGFloat
                let photoHeight: CGFloat

                if let photoUIImage = createRouteImageModel.photoUIImage {
                  photoWidth = photoUIImage.size.width
                  photoHeight = photoUIImage.size.height
                } else {
                  photoWidth = geometry.size.width
                  photoHeight = geometry.size.height
                }

                // Calculate ratios between view coordinates and actual image coordinates
                let xCordRatio = Int(photoWidth) / Int(geometry.size.width)
                let yCordRatio = Int(photoHeight) / Int(geometry.size.height)

                // Convert view coordinates to image coordinates
                let xCord = Int(value.location.x) * xCordRatio
                let yCord = Int(value.location.y) * yCordRatio
                createRouteImageModel.addPointToImage(CGPoint(x: xCord, y: yCord))
              }
              .onEnded { value in
                createRouteImageModel.createRouteImage()
                guard let photoImage = createRouteImageModel.photoImage,
                  let routeImage = createRouteImageModel.routeImage
                else {
                  return
                }
                createRouteImageModel.createRouteImageFromView(
                  fromView: viewFromTwoImages(image1: photoImage, image2: routeImage))
                createRouteImageModel.imageCreatingState = .isShowingPhoto
              }
          )
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}
