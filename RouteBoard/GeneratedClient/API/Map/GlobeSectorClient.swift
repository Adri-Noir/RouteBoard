// Created with <3 on 15.03.2025.

import OpenAPIURLSession

public typealias GetGlobeSectorCommand = Operations
  .get_sol_api_sol_Map_sol_globe_sol_sectors_sol__lcub_cragId_rcub_.Input.Path
public typealias GlobeSectorDto = Components.Schemas.GlobeSectorResponseDto

public class GlobeSectorClient: AuthenticatedClientProvider {
  public typealias T = GetGlobeSectorCommand
  public typealias R = [GlobeSectorDto]?

  public func call(
    _ data: T, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> R {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Map_sol_globe_sol_sectors_sol__lcub_cragId_rcub_(
          Operations.get_sol_api_sol_Map_sol_globe_sol_sectors_sol__lcub_cragId_rcub_.Input(
            path: data
          )
        )

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return nil

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GlobeSectorClient", errorHandler)
        return nil

      case .notFound(let error):
        handleNotFound(try? error.body.json.additionalProperties, errorHandler)
        return nil

      case .undocumented:
        handleUndocumented(errorHandler)
        return nil
      }
    } catch {
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return nil
  }

  public func cancel() {
    cancelRequest()
  }
}
