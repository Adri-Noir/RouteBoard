//
//  AuthenticationCheckerClient.swift
//  RouteBoard
//
//  Created with <3 on 05.01.2025..
//

public class AuthenticationCheckerClient: AuthenticatedClientProvider {
  public typealias T = Never?
  public typealias R = Bool

  public func call(
    _ data: Never? = nil, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> Bool {
    do {
      let result = try await getClient(authData).client
        .post_sol_api_sol_Authentication_sol_authenticated()

      switch result {
      case .ok:
        return true

      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return false

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "AuthenticationCheckerClient", errorHandler)
        return false

      case .undocumented:
        handleUndocumented(errorHandler)
        return false
      }

    } catch {
      errorHandler?(returnUnknownError())
    }

    return false
  }

  public func cancel() {
    cancelRequest()
  }
}
