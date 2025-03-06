//
//  MeClient.swift
//  RouteBoard
//
//  Created with <3 on 06.01.2025..
//

public class MeClient: AuthenticatedClientProvider {
  public typealias T = Void
  public typealias R = LoggedInUser?

  public func call(
    _ data: Void, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  )
    async -> LoggedInUser?
  {
    do {
      let result = try await getClient(authData).client.post_sol_api_sol_Authentication_sol_me()

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.json.additionalProperties, authData, errorHandler)

      case .badRequest(let error):
        handleBadRequest(try? error.body.json.additionalProperties, "MeClient", errorHandler)

      case .undocumented:
        handleUndocumented(errorHandler)
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
