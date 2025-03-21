//
//  LoginClient.swift
//  RouteBoard
//
//  Created with <3 on 04.01.2025..
//

public typealias LoginInput = Components.Schemas.LoginCommand
public typealias LoggedInUser = Components.Schemas.LoggedInUserDto

public class LoginClient: NonAuthenticatedClientProvider {
  public typealias T = LoginInput
  public typealias R = LoggedInUser?

  public func call(_ data: LoginInput, _ errorHandler: ((_ message: String) -> Void)? = nil) async
    -> LoggedInUser?
  {
    do {
      let input = Operations.post_sol_api_sol_Authentication_sol_login.Input(
        body: Operations.post_sol_api_sol_Authentication_sol_login.Input.Body.json(
          data))
      let result = try await getClient().client.post_sol_api_sol_Authentication_sol_login(input)

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "LoginClient", errorHandler)

      case .undocumented:
        handleUndocumented(errorHandler)

      case .unauthorized(let error):
        handleUnauthorized(
          try? error.body.json.additionalProperties, errorHandler)
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
