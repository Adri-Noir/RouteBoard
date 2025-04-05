//
//  RouteLink.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import SwiftUI

struct RouteLink<Content: View>: View {
  @Binding var routeId: String?
  @ViewBuilder var content: Content

  @EnvironmentObject var navigationManager: NavigationManager

  init(routeId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._routeId = routeId
    self.content = content()
  }

  init(routeId: String, @ViewBuilder content: @escaping () -> Content) {
    self._routeId = .constant(routeId)
    self.content = content()
  }

  var body: some View {
    Button(action: {
      navigationManager.pushView(.routeDetails(id: routeId ?? ""))
    }) {
      content
    }
  }
}
