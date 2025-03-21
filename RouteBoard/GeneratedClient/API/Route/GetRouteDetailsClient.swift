import OpenAPIURLSession

public typealias RouteDetailsInput = Operations.get_sol_api_sol_Route_sol__lcub_id_rcub_.Input.Path
public typealias RouteDetails = Components.Schemas.RouteDetailedDto
public typealias RoutePhoto = Components.Schemas.RoutePhotoDto

public class GetRouteDetailsClient: AuthenticatedClientProvider {
  public typealias T = RouteDetailsInput
  public typealias R = RouteDetails?

  public func call(
    _ data: RouteDetailsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> RouteDetails? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Route_sol__lcub_id_rcub_(
          Operations.get_sol_api_sol_Route_sol__lcub_id_rcub_.Input(
            path: data))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.json.additionalProperties, authData, errorHandler)
        return nil

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GetRouteDetailsClient", errorHandler)
        return nil

      case .notFound(let error):
        handleNotFound(try? error.body.json.additionalProperties, errorHandler)
        return nil

      case .undocumented:
        handleUndocumented(errorHandler)
        return nil
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
