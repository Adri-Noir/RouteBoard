//
//  GetSectorDetails.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 26.12.2024..
//

import OpenAPIURLSession

public typealias SectorDetails = Components.Schemas.SectorDetailedDto;

public struct GetSectorDetailsClient {
    private let client = ClientPicker.getClient()

    public init() {
    }

    public func getSectorDetails(sectorId: String) async -> SectorDetails? {
        do {
            let result = try await client.get_sol_api_sol_Sector_sol__lcub_id_rcub_(Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input(path: Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input.Path(id: sectorId)))

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
