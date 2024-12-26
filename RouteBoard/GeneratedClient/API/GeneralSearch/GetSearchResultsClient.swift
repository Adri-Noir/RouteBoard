//
//  GetSearchResults.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

import OpenAPIURLSession

public typealias GetSearchResults = Components.Schemas.SearchResultItemDto;

public struct GetSearchResultsClient {
    let client = ClientPicker.getClient()

    public init() {
    }

    public func search(value: String) async -> [GetSearchResults] {

        do {
            let result = try await client.post_sol_api_sol_Search(Operations.post_sol_api_sol_Search.Input(body: .json(Components.Schemas.SearchQueryCommand(query: value))))
            switch result {

            case let .ok(okResponse):
                switch okResponse.body {
                case .json(let value):
                    return value.items ?? [];
                case .plainText(_):
                    return []
                case .text_json(_):
                    return []
                }

            case .undocumented(statusCode: _, _):
                return []
            }
        } catch {
            print(error)
        }

        return []
    }
}
