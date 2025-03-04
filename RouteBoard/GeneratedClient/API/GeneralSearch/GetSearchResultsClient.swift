//
//  GetSearchResults.swift
//  RouteBoard
//
//  Created with <3 on 25.12.2024..
//

import OpenAPIURLSession

public typealias GetSearchResultsInput = Components.Schemas.SearchQueryCommand
public typealias GetSearchResults = Components.Schemas.SearchResultItemDto

public class GetSearchResultsClient: AuthenticatedClientProvider {
  public typealias T = GetSearchResultsInput
  public typealias R = [GetSearchResults]

  public func call(
    _ data: GetSearchResultsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> [GetSearchResults] {
    do {
      let result = try await self.getClient(authData).post_sol_api_sol_Search(
        Operations.post_sol_api_sol_Search.Input(
          body: .json(data)))

      switch result {

      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value.items ?? []
        }

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GetSearchResultsClient", errorHandler)
        return []

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return []

      case .undocumented:
        handleUndocumented(errorHandler)
        return []
      }
    } catch {
      print(error)
    }

    return []
  }
}
