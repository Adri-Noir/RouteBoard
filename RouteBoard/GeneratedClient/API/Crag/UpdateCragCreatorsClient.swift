// Created with <3 on 29.05.2025.

import OpenAPIURLSession

public struct UpdateCragCreatorsInput {
  public let cragId: String
  public let userIds: [String]?

  public init(cragId: String, userIds: [String]? = nil) {
    self.cragId = cragId
    self.userIds = userIds
  }
}

public class UpdateCragCreatorsClient: AuthenticatedClientProvider {
  public typealias T = UpdateCragCreatorsInput
  public typealias R = Void?

  public func call(
    _ data: UpdateCragCreatorsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> Void? {
    do {
      let result = try await getClient(authData).client
        .put_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users(
          Operations.put_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users.Input(
            path: Operations.put_sol_api_sol_Crag_sol__lcub_id_rcub__sol_users.Input.Path(
              id: data.cragId
            ),
            body: .json(
              Components.Schemas.UpdateCragCreatorsDto(
                userIds: data.userIds
              )
            )
          )
        )

      switch result {
      case .ok:
        return ()
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "UpdateCragCreatorsClient", errorHandler)
        return nil
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return nil
      case .forbidden(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "UpdateCragCreatorsClient", errorHandler)
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
