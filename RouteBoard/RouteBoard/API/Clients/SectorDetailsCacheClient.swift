// Created with <3 on 12.03.2025.

import GeneratedClient

class SectorDetailsCacheClient: AuthenticationClientProtocol, ObservableObject {
  private let sectorDetailsClient = GetSectorDetailsClient()
  private let cache = APICache<SectorDetailsInput, SectorDetails>()

  func call(
    _ data: SectorDetailsInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> SectorDetails? {
    if let cached = cache.get(key: data) {
      return cached
    }

    let result = await sectorDetailsClient.call(data, authData, errorHandler)
    cache.set(key: data, value: result)
    return result
  }

  func cancel() {
    sectorDetailsClient.cancel()
  }

  func clearCache() {
    cache.clear()
  }
}
