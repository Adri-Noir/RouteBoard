// Created with <3 on 19.04.2025.

import OpenAPIURLSession

public typealias DeleteRouteInput = Operations.delete_sol_api_sol_Route_sol__lcub_id_rcub_.Input
  .Path

public class DeleteRouteClient: AuthenticatedClientProvider {
  public typealias T = DeleteRouteInput
  public typealias R = Bool

  public func call(
    _ data: DeleteRouteInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> Bool {
    do {
      let result = try await getClient(authData).client.delete_sol_api_sol_Route_sol__lcub_id_rcub_(
        Operations.delete_sol_api_sol_Route_sol__lcub_id_rcub_.Input(path: data))

      switch result {
      case .ok:
        return true
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "DeleteRouteClient", errorHandler)
      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)
      case .undocumented:
        handleUndocumented(errorHandler)
        return false
      }
    } catch {
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }
    return false
  }

  public func cancel() {
    cancelRequest()
  }
}
