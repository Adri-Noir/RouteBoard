//
//  GetCragDetailsClient.swift
//  RouteBoard
//
//  Created with <3 on 01.01.2025..
//

public typealias CragDetailsInput = Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub_.Input.Path
public typealias CragDetails = Components.Schemas.CragDetailedDto

public class GetCragDetailsClient: AuthenticatedClientProvider {
  public typealias T = CragDetailsInput
  public typealias R = CragDetails?

  public func call(_ data: CragDetailsInput, _ authData: AuthData) async -> CragDetails? {
    do {
      let result = try await self.getClient(authData).get_sol_api_sol_Crag_sol__lcub_id_rcub_(
        Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub_.Input(
          path: data))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized:
        await authData.unauthorizedHandler?()
        return nil

      case .undocumented(statusCode: _, _):
        return nil
      }
    } catch {
      print(error)
    }

    return nil
  }
}
