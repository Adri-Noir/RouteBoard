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
  let viewSize: CGSize

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
                let touchLocation = value.location
                createRouteImageModel.addPointToCanvas(touchLocation)

                // Ensure we have the original photo dimensions
                guard let photoUIImage = createRouteImageModel.photoUIImage else {
                  print("Error: Missing photoUIImage for coordinate calculation.")
                  return
                }
                let imageSize = photoUIImage.size

                // --- New Coordinate Mapping Logic for .scaledToFill() ---

                let viewWidth = viewSize.width
                let viewHeight = viewSize.height
                let imageWidth = imageSize.width
                let imageHeight = imageSize.height

                let viewAspect = viewWidth / viewHeight
                let imageAspect = imageWidth / imageHeight

                var scale: CGFloat = 1.0
                var scaledImageSize = imageSize
                var offset = CGPoint.zero

                if imageAspect > viewAspect {
                  // Image is wider than the view; scaled to fill height, width cropped
                  scale = viewHeight / imageHeight
                  scaledImageSize = CGSize(width: imageWidth * scale, height: viewHeight)
                  // Calculate the horizontal offset of the visible area within the scaled image
                  offset.x = (scaledImageSize.width - viewWidth) / 2.0
                } else {
                  // Image is taller than or equal aspect to the view; scaled to fill width, height cropped
                  scale = viewWidth / imageWidth
                  scaledImageSize = CGSize(width: viewWidth, height: imageHeight * scale)
                  // Calculate the vertical offset of the visible area within the scaled image
                  offset.y = (scaledImageSize.height - viewHeight) / 2.0
                }

                // Map touch location in view coordinates to image coordinates
                // 1. Adjust touch location by the offset to find its position within the scaled (but potentially larger than view) image
                let touchXOnScaledImage = touchLocation.x + offset.x
                let touchYOnScaledImage = touchLocation.y + offset.y

                // 2. Convert the position on the scaled image back to the original image's coordinate system
                let imageX = touchXOnScaledImage / scale
                let imageY = touchYOnScaledImage / scale

                // --- End of New Logic ---

                createRouteImageModel.addPointToImage(CGPoint(x: imageX, y: imageY))
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
      .frame(width: viewSize.width, height: viewSize.height)
    }
  }
}
