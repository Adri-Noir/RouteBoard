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
  let isOfflineMode: Bool

  @EnvironmentObject var navigationManager: NavigationManager

  init(
    routeId: Binding<String?>, isOfflineMode: Bool, @ViewBuilder content: @escaping () -> Content
  ) {
    self._routeId = routeId
    self.content = content()
    self.isOfflineMode = isOfflineMode
  }

  init(routeId: String, isOfflineMode: Bool, @ViewBuilder content: @escaping () -> Content) {
    self._routeId = .constant(routeId)
    self.content = content()
    self.isOfflineMode = isOfflineMode
  }

  var body: some View {
    Button(action: {
      if isOfflineMode {
        navigationManager.pushView(.offlineRoute(routeId: routeId ?? ""))
      } else {
        navigationManager.pushView(.routeDetails(id: routeId ?? ""))
      }
    }) {
      content
    }
  }
}
