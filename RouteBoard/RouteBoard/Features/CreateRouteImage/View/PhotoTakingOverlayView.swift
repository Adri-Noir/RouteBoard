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
    // Empty view - the capture button has been moved to the main view
    EmptyView()
  }
}
