// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias ExploreDto = Components.Schemas.ExploreDto

public class ExploreClient: AuthenticatedClientProvider {
  public typealias T = Operations.get_sol_api_sol_Map_sol_explore.Input.Query
  public typealias R = [ExploreDto]?

  public func call(
    _ data: T, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> R {
    do {
      let result = try await getClient(authData).client.get_sol_api_sol_Map_sol_explore(
        Operations.get_sol_api_sol_Map_sol_explore.Input(
          query: data
        )
      )

      switch result {
      case .ok(let body):
        return try body.body.json

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return nil

      case .badRequest(let error):
        handleBadRequest(try? error.body.json.additionalProperties, "ExploreClient", errorHandler)
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
