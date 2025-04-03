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

  public func call(
    _ data: CragDetailsInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CragDetails? {
    do {
      let result = try await getClient(authData).client.get_sol_api_sol_Crag_sol__lcub_id_rcub_(
        Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub_.Input(
          path: data))

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
          try? error.body.application_problem_plus_json, "GetCragDetailsClient", errorHandler)

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
