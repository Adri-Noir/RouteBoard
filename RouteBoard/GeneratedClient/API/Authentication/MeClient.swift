//
//  MeClient.swift
//  RouteBoard
//
//  Created with <3 on 06.01.2025..
//

public class MeClient: AuthenticatedClientProvider {
  public typealias T = Never?
  public typealias R = LoggedInUser?

  public func call(_ data: Never? = nil, _ authData: AuthData)
    async -> LoggedInUser?
  {
    do {
      let result = try await self.getClient(authData).post_sol_api_sol_Authentication_sol_me()

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized:
        // await self.runUnauthorizedHandler()
        return nil

      default:
        return nil
      }

    } catch {
      print(error)
    }

    return nil
  }
}
