// Created with <3 on 09.03.2025.

import GeneratedClient

class CragWeatherCacheClient: AuthenticationClientProtocol, ObservableObject {
  private let cragWeatherClient = GetCragWeatherClient()
  private let cache = APICache<CragWeatherInput, CragWeather>()

  func call(
    _ data: CragWeatherInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CragWeather? {
    if let cached = cache.get(key: data) {
      return cached
    }

    let result = await cragWeatherClient.call(data, authData, errorHandler)
    cache.set(key: data, value: result)
    return result
  }

  func cancel() {
    cragWeatherClient.cancel()
  }

  func clearCache() {
    cache.clear()
  }
}
