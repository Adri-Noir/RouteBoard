// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias UserRecentAscents = Components.Schemas.RouteDetailedDto

public class UserRecentAscentsClient: AuthenticatedClientProvider {
  public typealias T = Void
  public typealias R = [UserRecentAscents]

  public func call(_ data: Void, _ authData: AuthData) async -> [UserRecentAscents] {
    do {
      let result = try await self.getClient(authData)
        .get_sol_api_sol_User_sol_recentlyAscendedRoutes()
      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest:
        return []
      case .unauthorized:
        await authData.unauthorizedHandler?()
        return []
      case .undocumented:
        return []
      }
    } catch (let error) {
      print("Error: \(error)")
    }

    return []
  }
}
