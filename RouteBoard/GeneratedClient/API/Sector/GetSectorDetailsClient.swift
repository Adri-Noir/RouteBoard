//
//  GetSectorDetails.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 26.12.2024..
//

import OpenAPIURLSession

public typealias SectorDetailsInput = Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input
  .Path
public typealias SectorDetails = Components.Schemas.SectorDetailedDto

public class GetSectorDetailsClient: AuthenticatedClientProvider {
  public typealias T = SectorDetailsInput
  public typealias R = SectorDetails?

  public func call(_ data: SectorDetailsInput, _ authData: AuthData) async -> SectorDetails? {
    do {
      let result = try await self.getClient(authData).get_sol_api_sol_Sector_sol__lcub_id_rcub_(
        Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input(
          path: data))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized:
        await authData.unauthorizedHandler?()
        return nil

      case .undocumented(statusCode: _, _):
        return nil
      }
    } catch {
      print(error)
    }

    return nil
  }
}
