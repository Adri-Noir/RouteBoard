//
//  CreateRouteOverlayView.swift
//  RouteBoard
//
//  Created with <3 on 06.07.2024..
//

import SwiftUI
import opencv2

// This view is no longer used - kept for reference
struct CreateRouteOverlayView<Content: View>: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel
  @ViewBuilder var content: Content

  var body: some View {
    // Empty implementation - functionality moved to CreateRouteImageView
    content
  }
}
