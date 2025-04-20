// Created with <3 on 20.04.2025.

import OpenAPIURLSession

public typealias EditRouteCommand = Components.Schemas.EditRouteCommand

public class EditRouteClient: AuthenticatedClientProvider {
  public typealias T = (id: String, command: EditRouteCommand)
  public typealias R = RouteDetailedDto?

  public func call(
    _ data: (id: String, command: EditRouteCommand),
    _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)?
  ) async -> RouteDetailedDto? {
    do {
      let result = try await getClient(authData).client.put_sol_api_sol_Route_sol__lcub_id_rcub_(
        Operations.put_sol_api_sol_Route_sol__lcub_id_rcub_.Input(
          path: .init(id: data.id),
          body: .json(data.command)
        )
      )

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "EditRouteClient", errorHandler)
      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)
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
