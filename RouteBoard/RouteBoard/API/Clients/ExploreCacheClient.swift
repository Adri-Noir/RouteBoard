// Created with <3 on 06.03.2025.

import GeneratedClient

class ExploreCacheClient: AuthenticationClientProtocol, ObservableObject {
  private let exploreClient = ExploreClient()
  private let cache = APICache<
    Operations.get_sol_api_sol_Map_sol_explore.Input.Query, [ExploreDto]
  >()

  func call(
    _ data: Operations.get_sol_api_sol_Map_sol_explore.Input.Query, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> [ExploreDto]? {
    if let cached = cache.get(key: data) {
      return cached
    }

    let result = await exploreClient.call(data, authData, errorHandler)
    cache.set(key: data, value: result)
    return result
  }

  func cancel() {
    exploreClient.cancel()
  }

  func clearCache() {
    cache.clear()
  }
}
