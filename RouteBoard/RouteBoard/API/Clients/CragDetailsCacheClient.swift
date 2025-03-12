// Created with <3 on 12.03.2025.

import GeneratedClient

class CragDetailsCacheClient: AuthenticationClientProtocol, ObservableObject {
  private let cragDetailsClient = GetCragDetailsClient()
  private let cache = APICache<CragDetailsInput, CragDetails>()

  func call(
    _ data: CragDetailsInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CragDetails? {
    if let cached = cache.get(key: data) {
      return cached
    }

    let result = await cragDetailsClient.call(data, authData, errorHandler)
    cache.set(key: data, value: result)
    return result
  }

  func cancel() {
    cragDetailsClient.cancel()
  }

  func clearCache() {
    cache.clear()
  }
}
