// Created with <3 on 18.05.2025.

import SwiftData
import SwiftUI

@MainActor
struct ModelInjection<Content: View>: View {
  @Environment(\.modelContext) private var modelContext

  let content: () -> Content

  var body: some View {
    content()
      .modelContainer(for: [
        DownloadedRoute.self, DownloadedRoutePhoto.self, DownloadedSector.self, DownloadedCrag.self,
      ])
  }
}
