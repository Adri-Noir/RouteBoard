//
//  GetCragDetailsClient.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.01.2025..
//

public typealias CragDetails = Components.Schemas.CragDetailedDto

public struct GetCragDetailsClient {
    private let client = ClientPicker.getClient()

    public init() {
    }

    public func getCragDetails(cragId: String) async -> CragDetails? {
        do {
            let result = try await client.get_sol_api_sol_Crag_sol__lcub_id_rcub_(Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub_.Input(path: Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub_.Input.Path(id: cragId)))

            switch result {
            case let .ok(okResponse):
                switch okResponse.body {
                case .json(let value):
                    return value
                }

            case .undocumented(statusCode: _, _):
                return nil
            }
        } catch {
            print(error)
        }

        return nil
    }
}
