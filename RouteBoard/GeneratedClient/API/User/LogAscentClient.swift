// Created with <3 on 27.02.2025.

import OpenAPIURLSession

public typealias LogAscentInput = Components.Schemas.LogAscentCommand

public class LogAscentClient: AuthenticatedClientProvider {
  public typealias T = LogAscentInput
  public typealias R = Bool

  public func call(_ data: LogAscentInput, _ authData: AuthData) async -> Bool {
    do {
      let result = try await self.getClient(authData)
        .post_sol_api_sol_User_sol_logAscent(
          Operations.post_sol_api_sol_User_sol_logAscent.Input(
            body: .json(data)))

      switch result {
      case .ok:
        return true

      case .unauthorized:
        await authData.unauthorizedHandler?()
        return false

      case .undocumented:
        return false
      }
    } catch {
      print(error)
    }

    return false
  }
}
