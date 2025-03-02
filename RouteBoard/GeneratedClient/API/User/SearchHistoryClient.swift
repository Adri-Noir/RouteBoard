// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias SearchHistory = Components.Schemas.SearchHistoryDto

public class SearchHistoryClient: AuthenticatedClientProvider {
  public typealias R = [SearchHistory]

  public func call(_ data: Void, _ authData: AuthData) async -> [SearchHistory] {
    do {
      let result = try await self.getClient(authData)
        .get_sol_api_sol_User_sol_searchHistory()

      switch result {
      case .ok(let response):
        switch response.body {
        case .json(let value):
          return value
        }

      case .unauthorized:
        await authData.unauthorizedHandler?()
        return []

      case .undocumented:
        return []
      }
    } catch {
      print(error)
    }

    return []
  }
}
