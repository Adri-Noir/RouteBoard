//
//  RouteLink.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import SwiftUI

struct RouteLink<Content: View>: View {
  @Binding var routeId: String?
  let nonBindingRouteId: String?
  @ViewBuilder var content: Content

  init(routeId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._routeId = routeId
    self.content = content()
    self.nonBindingRouteId = nil
  }

  init(routeId: String, @ViewBuilder content: @escaping () -> Content) {
    self._routeId = .constant(nil)
    self.nonBindingRouteId = routeId
    self.content = content()
  }

  var body: some View {
    NavigationLink(destination: RouteView(routeId: routeId ?? nonBindingRouteId ?? "")) {
      content
    }
  }
}
