import OpenAPIURLSession

public typealias RouteDetailsInput = Operations.get_sol_api_sol_Route_sol__lcub_id_rcub_.Input.Path
public typealias RouteDetails = Components.Schemas.RouteDetailedDto

public class GetRouteDetailsClient: AuthenticatedClientProvider {
  public typealias T = RouteDetailsInput
  public typealias R = RouteDetails?

  public func call(_ data: RouteDetailsInput, _ authData: AuthData) async -> RouteDetails? {
    do {
      let result = try await self.getClient(authData).get_sol_api_sol_Route_sol__lcub_id_rcub_(
        Operations.get_sol_api_sol_Route_sol__lcub_id_rcub_.Input(
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
