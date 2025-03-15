// Created with <3 on 15.03.2025.

import OpenAPIURLSession

public typealias GetGlobeCommand = Components.Schemas.GetGlobeCommand
public typealias GlobeDto = Components.Schemas.GlobeResponseDto

public class GlobeClient: AuthenticatedClientProvider {
  public typealias T = GetGlobeCommand
  public typealias R = [GlobeDto]?

  public func call(
    _ data: T, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> R {
    do {
      let result = try await getClient(authData).client.post_sol_api_sol_Map_sol_globe(
        Operations.post_sol_api_sol_Map_sol_globe.Input(
          body: .json(data)
        )
      )

      switch result {
      case .ok(let body):
        return try body.body.json

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return nil

      case .badRequest(let error):
        handleBadRequest(try? error.body.json.additionalProperties, "GlobeClient", errorHandler)
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
