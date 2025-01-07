//
//  LoginClient.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.01.2025..
//

public typealias LoginInput = Components.Schemas.LoginCommand
public typealias LoggedInUser = Components.Schemas.LoggedInUserDto

public class LoginClient: NonAuthenticatedClientProvider {
  public typealias T = LoginInput
  public typealias R = LoggedInUser?

  public func call(_ data: LoginInput) async -> LoggedInUser? {
    do {
      let input = Operations.post_sol_api_sol_Authentication_sol_login.Input(
        body: Operations.post_sol_api_sol_Authentication_sol_login.Input.Body.json(
          data))
      let result = try await self.getClient().post_sol_api_sol_Authentication_sol_login(input)

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      default:
        return nil
      }

    } catch {
      print(error)
    }

    return nil
  }
}
