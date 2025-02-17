//
//  AuthenticationCheckerClient.swift
//  RouteBoard
//
//  Created with <3 on 05.01.2025..
//

public class AuthenticationCheckerClient: AuthenticatedClientProvider {
  public typealias T = Never?
  public typealias R = Bool

  public func call(_ data: Never? = nil, _ authData: AuthData)
    async -> Bool
  {
    do {
      let result = try await self.getClient(authData)
        .post_sol_api_sol_Authentication_sol_authenticated()

      switch result {
      case .ok: return true
      case .unauthorized:
        // await self.runUnauthorizedHandler()
        return false

      default: return false
      }

    } catch {
      print(error)
    }

    return false
  }

}
