//
//  ConfirmPhotoOverlayView.swift
//  RouteBoard
//
//  Created with <3 on 21.12.2024..
//

import SwiftUI

struct ConfirmPhotoOverlayView: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel
  let onRetake: () -> Void
  let onRedraw: () -> Void
  let onFinish: () -> Void

  // Styled button view
  func styledButton(_ text: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(text)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    .padding(8)
  }

  var body: some View {
    VStack {
      ZStack {
        GeometryReader { geometry in
          if createRouteImageModel.isShowingTakenPhoto {
            createRouteImageModel.combinedUIImage?
              .resizable()
              .scaledToFill()
              .frame(width: geometry.size.width, height: geometry.size.height)
              .cornerRadius(20)
          }
        }
        // When in drawing mode, just show Retake
        if createRouteImageModel.imageCreatingState != .isCurrentlyDrawing {
          VStack {
            Spacer()

            HStack(spacing: 12) {
              styledButton("Retake photo") {
                onRetake()
              }

              Spacer()

              styledButton("Redraw route") {
                onRedraw()
              }
            }
          }
          .padding(.horizontal)
        }
      }

      // Finish button
      if !createRouteImageModel.isEditingPhoto {
        Button(action: onFinish) {
          Text(createRouteImageModel.isUploading ? "Uploading..." : "Finish")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
        }
        .background(createRouteImageModel.isUploading ? Color.gray : Color.newPrimaryColor)
        .disabled(createRouteImageModel.isUploading)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 5)
      }
    }
  }
}
