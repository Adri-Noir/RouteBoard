// Created with <3 on 12.03.2025.

import GeneratedClient

class RouteDetailsCacheClient: AuthenticationClientProtocol, ObservableObject {
  private let routeDetailsClient = GetRouteDetailsClient()
  private let cache = APICache<RouteDetailsInput, RouteDetails>()

  func call(
    _ data: RouteDetailsInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> RouteDetails? {
    if let cached = cache.get(key: data) {
      return cached
    }

    let result = await routeDetailsClient.call(data, authData, errorHandler)
    cache.set(key: data, value: result)
    return result
  }

  func cancel() {
    routeDetailsClient.cancel()
  }

  func clearCache() {
    cache.clear()
  }
}
