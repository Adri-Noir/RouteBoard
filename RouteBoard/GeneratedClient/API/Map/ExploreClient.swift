// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias ExploreDto = Components.Schemas.ExploreDto

public class ExploreClient: AuthenticatedClientProvider {
  public typealias T = Operations.get_sol_api_sol_Map_sol_explore.Input.Query
  public typealias R = [ExploreDto]

  public func call(_ data: T, _ authData: AuthData) async -> R {
    do {
      let result = try await self.getClient(authData).get_sol_api_sol_Map_sol_explore(
        Operations.get_sol_api_sol_Map_sol_explore.Input(
          query: data
        )
      )

      switch result {
      case .ok(let body):
        return try body.body.json
      case .unauthorized:
        await authData.unauthorizedHandler?()
      case .undocumented:
        return []
      }
    } catch {
      print(error)
    }

    return []
  }
}
