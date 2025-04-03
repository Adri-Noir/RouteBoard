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
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return false

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "AuthenticationCheckerClient", errorHandler
        )
        return false

      case .undocumented:
        handleUndocumented(errorHandler)
        return false
      }

    } catch {
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return false
  }

  public func cancel() {
    cancelRequest()
  }
}
