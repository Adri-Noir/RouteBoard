// Created with <3 on 13.03.2025.

import OpenAPIURLSession

public typealias SectorCragDetailsInput = Operations
  .get_sol_api_sol_Sector_sol_sectorCrag_sol__lcub_id_rcub_.Input.Path

public class GetSectorCragDetailsClient: AuthenticatedClientProvider {
  public typealias T = SectorCragDetailsInput
  public typealias R = CragDetails?

  public func call(
    _ data: SectorCragDetailsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> CragDetails? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Sector_sol_sectorCrag_sol__lcub_id_rcub_(path: data)

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
          try? error.body.json.additionalProperties, "GetSectorCragDetailsClient", errorHandler)
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
