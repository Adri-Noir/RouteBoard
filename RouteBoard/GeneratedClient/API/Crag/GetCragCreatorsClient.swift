// Created with <3 on 29.05.2025.

import OpenAPIURLSession

public typealias GetCragCreatorsInput = Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users
  .Input.Path
public typealias GetCragCreatorsOutput = [Components.Schemas.UserRestrictedDto]

public class GetCragCreatorsClient: AuthenticatedClientProvider {
  public typealias T = GetCragCreatorsInput
  public typealias R = GetCragCreatorsOutput?

  public func call(
    _ data: GetCragCreatorsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> GetCragCreatorsOutput? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users(
          Operations.get_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users.Input(
            path: data
          )
        )

      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetCragCreatorsClient", errorHandler)
        return nil
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return nil
      case .forbidden(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetCragCreatorsClient", errorHandler)
        return nil
      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)
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
