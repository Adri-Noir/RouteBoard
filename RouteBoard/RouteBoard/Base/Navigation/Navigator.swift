// Created with <3 on 05.04.2025.

import Foundation
import SwiftUI

struct Navigator<Content: View>: View {
  let content: (NavigationManager) -> Content
  @StateObject var manager = NavigationManager()

  var body: some View {
    NavigationStack(path: $manager.routes) {
      content(manager)
        .routeIterator()
    }
    .environmentObject(manager)
  }
}

extension View {
  func routeIterator() -> some View {
    self.navigationDestination(for: NavigationPaths.self) { path in
      Routes.routerReturner(path: path)
    }
  }
}
