// Created with <3 on 06.03.2025.

import GeneratedClient
import SwiftUI

struct APIClientInjection<Content: View>: View {
  private let exploreCacheClient = ExploreCacheClient()

  @ViewBuilder let content: () -> Content

  var body: some View {
    content()
      .environmentObject(exploreCacheClient)
  }
}
