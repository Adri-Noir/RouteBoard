//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import SwiftUI

struct RouteFinderView: View {
  var routeSamples: [DetectSample]
  @StateObject private var routeImageModel = RouteImageModel()
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack(alignment: .bottom) {
      GeometryReader { geometry in
        ViewFinderView(image: $routeImageModel.viewfinderImage)
          .background(.black)
      }
      .task {
        await routeImageModel.startCamera()
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(true)
      .ignoresSafeArea()
      .statusBar(hidden: true)

      RouteFinderBottomInfoView(routeImageModel: routeImageModel)
    }
    .task {
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
