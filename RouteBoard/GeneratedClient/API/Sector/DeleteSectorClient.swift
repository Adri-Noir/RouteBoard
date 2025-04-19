// Created with <3 on 19.04.2025.

import OpenAPIURLSession

public typealias DeleteSectorInput = Operations.delete_sol_api_sol_Sector_sol__lcub_id_rcub_.Input
  .Path

public class DeleteSectorClient: AuthenticatedClientProvider {
  public typealias T = DeleteSectorInput
  public typealias R = Bool

  public func call(
    _ data: DeleteSectorInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> Bool {
    do {
      let result = try await getClient(authData).client
        .delete_sol_api_sol_Sector_sol__lcub_id_rcub_(
          Operations.delete_sol_api_sol_Sector_sol__lcub_id_rcub_.Input(path: data))

      switch result {
      case .ok:
        return true
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "DeleteSectorClient", errorHandler)
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
