// Created with <3 on 06.03.2025.

import GeneratedClient
import SwiftUI

struct APIClientInjection<Content: View>: View {
  private let exploreCacheClient = ExploreCacheClient()
  private let cragWeatherCacheClient = CragWeatherCacheClient()
  private let cragDetailsCacheClient = CragDetailsCacheClient()
  private let sectorDetailsCacheClient = SectorDetailsCacheClient()
  private let routeDetailsCacheClient = RouteDetailsCacheClient()

  @ViewBuilder let content: () -> Content

  var body: some View {
    content()
      .environmentObject(exploreCacheClient)
      .environmentObject(cragWeatherCacheClient)
      .environmentObject(cragDetailsCacheClient)
      .environmentObject(sectorDetailsCacheClient)
      .environmentObject(routeDetailsCacheClient)
  }
}
