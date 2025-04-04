// Created with <3 on 04.04.2025.

import OpenAPIURLSession

public typealias CreateRouteCommand = Components.Schemas.CreateRouteCommand
public typealias RouteDetailedDto = Components.Schemas.RouteDetailedDto

public class CreateRouteClient: AuthenticatedClientProvider {
  public typealias T = CreateRouteCommand
  public typealias R = RouteDetailedDto?

  public func call(
    _ data: CreateRouteCommand, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> RouteDetailedDto? {
    do {
      let result = try await getClient(authData).client.post_sol_api_sol_Route(
        Operations.post_sol_api_sol_Route.Input(
          body: .json(data)))

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
          try? error.body.application_problem_plus_json, "CreateRouteClient", errorHandler)

      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)

      case .undocumented:
        handleUndocumented(errorHandler)
        return nil
      }
    } catch (let error) {
      print(error)
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return nil
  }

  public func cancel() {
    cancelRequest()
  }
}
