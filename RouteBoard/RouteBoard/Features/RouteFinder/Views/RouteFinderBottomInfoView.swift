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
      Text("Looking at route: \(routeImageModel.closestRouteId ?? -1)")
    }
    .background(.black)
    .opacity(0.8)
    .frame(maxWidth: .infinity)
  }
}
