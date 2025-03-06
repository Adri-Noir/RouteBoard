// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias SearchHistory = Components.Schemas.SearchHistoryDto

public class SearchHistoryClient: AuthenticatedClientProvider {
  public typealias T = Void
  public typealias R = [SearchHistory]

  public func call(
    _ data: Void, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> [SearchHistory] {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_User_sol_searchHistory()

      switch result {
      case .ok(let response):
        switch response.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return []

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "SearchHistoryClient", errorHandler)
        return []

      case .undocumented:
        handleUndocumented(errorHandler)
        return []
      }
    } catch {
      errorHandler?(returnUnknownError())
    }

    return []
  }

  public func cancel() {
    cancelRequest()
  }
}
