//
//  GetSectorDetails.swift
//  RouteBoard
//
//  Created with <3 on 26.12.2024..
//

import OpenAPIURLSession

public typealias SectorDetailsInput = Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input
  .Path
public typealias SectorDetails = Components.Schemas.SectorDetailedDto
public typealias SectorRoute = Components.Schemas.SectorRouteDto

public class GetSectorDetailsClient: AuthenticatedClientProvider {
  public typealias T = SectorDetailsInput
  public typealias R = SectorDetails?

  public func call(
    _ data: SectorDetailsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> SectorDetails? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Sector_sol__lcub_id_rcub_(
          Operations.get_sol_api_sol_Sector_sol__lcub_id_rcub_.Input(
            path: data))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.json.additionalProperties, authData, errorHandler)
        return nil

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GetSectorDetailsClient", errorHandler)
        return nil

      case .notFound(let error):
        handleNotFound(try? error.body.json.additionalProperties, errorHandler)
        return nil

      case .undocumented:
        handleUndocumented(errorHandler)
        return nil
      }
    } catch {
      errorHandler?(returnUnknownError())
    }

    return nil
  }

  public func cancel() {
    cancelRequest()
  }
}
