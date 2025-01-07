//
//  GetSearchResults.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

import OpenAPIURLSession

public typealias GetSearchResultsInput = Components.Schemas.SearchQueryCommand
public typealias GetSearchResults = Components.Schemas.SearchResultItemDto

public class GetSearchResultsClient: AuthenticatedClientProvider {
  public typealias T = GetSearchResultsInput
  public typealias R = [GetSearchResults]

  public func call(_ data: GetSearchResultsInput, _ authData: AuthData) async -> [GetSearchResults]
  {
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

      case .unauthorized:
        await authData.unauthorizedHandler?()
        return []

      case .undocumented(statusCode: _, _):
        return []
      }
    } catch {
      print(error)
    }

    return []
  }
}
