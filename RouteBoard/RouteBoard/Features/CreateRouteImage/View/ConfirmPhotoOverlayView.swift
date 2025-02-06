//
//  ConfirmPhotoOverlayView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 21.12.2024..
//

import SwiftUI

struct ConfirmPhotoOverlayView: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .top) {
        GeometryReader { geometry in
          VStack {
            PhotoDrawingCanvas(createRouteImageModel: createRouteImageModel)
          }
          .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()

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

            Button {
              createRouteImageModel.resetToEditing()
            } label: {
              Text("Redraw route line")

            }
            .foregroundStyle(.white)
            .padding()
          }
        }
        .background(.black)
        .opacity(0.8)
        .frame(maxWidth: .infinity)
      }

      VStack {
        HStack {
          Spacer()

          Button {
            // createRouteImageModel.resetToEditing()
            dismiss()
          } label: {
            Text("Finish")

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
