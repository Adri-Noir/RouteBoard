//
//  PhotoEditingOverlayView.swift
//  RouteBoard
//
//  Created with <3 on 20.12.2024..
//

import SwiftUI

struct PhotoEditingOverlayView: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel

  var canvas: some View {
    GeometryReader { geometry in
      VStack {
        PhotoDrawingCanvas(createRouteImageModel: createRouteImageModel)
          .gesture(
            DragGesture(minimumDistance: 1)
              .onChanged { value in
                createRouteImageModel.imageCreatingState = .isCurrentlyDrawing
                createRouteImageModel.addPointToCanvas(value.location)

                let photoMatrixWidth =
                  createRouteImageModel.photoMatrix?.cols() ?? Int32(geometry.size.width)
                let photoMatrixHeight =
                  createRouteImageModel.photoMatrix?.rows() ?? Int32(geometry.size.height)

                let xCordRatio = Int(photoMatrixWidth) / Int(geometry.size.width)
                let yCordRatio = Int(photoMatrixHeight) / Int(geometry.size.height)

                let xCord = Int(value.location.x) * xCordRatio
                let yCord = Int(value.location.y) * yCordRatio
                createRouteImageModel.addPointToImage(CGPoint(x: xCord, y: yCord))
              }
              .onEnded { value in
                createRouteImageModel.createRouteImage()
                createRouteImageModel.imageCreatingState = .isShowingPhoto
              }
          )
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
  }

  var body: some View {
    ZStack(alignment: .top) {
      canvas

      if createRouteImageModel.imageCreatingState != .isCurrentlyDrawing {
        VStack {
          HStack {
            Button {
              createRouteImageModel.resetToPreview()
            } label: {
              Text("Retake photo")

            }
            .foregroundStyle(.white)
            .padding()

            Spacer()
          }
        }
        .background(.black)
        .opacity(0.8)
        .frame(maxWidth: .infinity)
      }
    }
  }
}
