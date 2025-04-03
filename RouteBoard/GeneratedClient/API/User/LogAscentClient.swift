// Created with <3 on 27.02.2025.

import OpenAPIURLSession

public typealias LogAscentInput = Components.Schemas.LogAscentCommand

public class LogAscentClient: AuthenticatedClientProvider {
  public typealias T = LogAscentInput
  public typealias R = String

  public func call(
    _ data: LogAscentInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> String {
    do {
      let result = try await getClient(authData).client
        .post_sol_api_sol_User_sol_logAscent(
          Operations.post_sol_api_sol_User_sol_logAscent.Input(
            body: .json(data)))

      switch result {
      case .ok:
        return ""

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "LogAscentClient", errorHandler)
        return ""

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return ""

      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)
        return ""

      case .undocumented:
        handleUndocumented(errorHandler)
        return ""
      }
    } catch {
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return ""
  }

  public func cancel() {
    cancelRequest()
  }
}
