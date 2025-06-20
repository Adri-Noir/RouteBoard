//
//  PhotoTakingView.swift
//  RouteBoard
//
//  Created with <3 on 20.12.2024..
//

import SwiftUI

struct PhotoTakingOverlayView: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel

  func removeAllPoints() {
    createRouteImageModel.canvasPoints.removeAll()
  }

  var body: some View {
    ZStack {
      if createRouteImageModel.isShowingPreview {
        CameraPreview(source: createRouteImageModel.getPreviewSource())

        VStack {
          Spacer()

          HStack {
            Spacer()

            PhotoCaptureButton {
              Task {
                await createRouteImageModel.takePhoto()
              }
            }
            .frame(width: 70, height: 70)

            Spacer()
          }
        }
        .padding(.bottom)
      }
    }
  }
}
