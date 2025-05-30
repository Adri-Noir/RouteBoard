//
//  RouteFinderBottomInfoView.swift
//  RouteBoard
//
//  Created with <3 on 03.07.2024..
//

import SwiftUI

struct RouteFinderBottomInfoView: View {
  @ObservedObject var routeImageModel: RouteImageModel
  @Environment(\.dismiss) var dismiss

  var body: some View {
    HStack {
      Spacer()
      if let route = routeImageModel.detectedRoute {
        Text("Looking at route: \(route.name ?? route.id)")
      } else if let downloadedRoute = routeImageModel.detectedDownloadedRoute {
        Text("Looking at route: \(downloadedRoute.name ?? downloadedRoute.id ?? "Unknown")")
      } else {
        Text("No route found")
      }
      Spacer()
    }
    .background(.black)
    .opacity(0.8)
    .frame(maxWidth: .infinity)
  }
}
