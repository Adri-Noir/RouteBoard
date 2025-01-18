//
//  CreateRouteImageView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import SwiftUI

struct CreateRouteImageView: View {
  @StateObject private var createRouteImageModel = CreateRouteImageModel()

  var body: some View {
    CreateRouteOverlayView(createRouteImageModel: createRouteImageModel) {
      CameraPreview(source: createRouteImageModel.getPreviewSource())
    }
  }
}

#Preview {
  CreateRouteImageView()
}
