//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import SwiftUI

struct RouteFinderView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  var routeId: String? = nil
  @State var routeSamples: [DetectSample] = []
  @State private var isLoading = false

  @StateObject private var routeImageModel = RouteImageModel()

  var body: some View {
    ZStack(alignment: .bottom) {
      if !isLoading {
        ViewFinderView(image: $routeImageModel.viewfinderImage)
          .background(.black)
          .task {
            await routeImageModel.startCamera()
          }
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarHidden(true)
          .ignoresSafeArea()
          .statusBar(hidden: true)

        RouteFinderBottomInfoView(routeImageModel: routeImageModel)
      }

      if isLoading {
        ZStack {
          Color.black
            .ignoresSafeArea()

          VStack {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(1.5)

            Text("Loading route...")
              .foregroundColor(.white)
              .padding(.top, 20)
          }
        }
      }
    }
    .task {
      isLoading = true
      defer { isLoading = false }
      if let routeId = routeId {
        routeSamples = await PhotoDownloader.downloadRoutePhotos(
          routeId: routeId, authViewModel: authViewModel)
        routeImageModel.processSamples(samples: routeSamples)
        return
      }

      routeImageModel.processSamples(samples: routeSamples)
    }
  }
}

#Preview {
  RouteFinderView(routeSamples: [
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/pikachu")!,
      path: UIImage.init(named: "TestingSamples/limski/pikachu_path")!, routeId: "1"),
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/hobotnica")!,
      path: UIImage.init(named: "TestingSamples/limski/hobotnica_path")!, routeId: "2"),
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/list")!,
      path: UIImage.init(named: "TestingSamples/limski/list_path")!, routeId: "3"),
  ])
}
