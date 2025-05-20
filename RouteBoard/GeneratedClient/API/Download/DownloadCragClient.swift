// Created with <3 on 18.05.2025.

import OpenAPIURLSession

public typealias DownloadCragInput = Operations.get_sol_api_sol_Download_sol_crag_sol__lcub_id_rcub_
  .Input.Path
public typealias DownloadCragResponse = Components.Schemas.DownloadCragResponse

public class DownloadCragClient: AuthenticatedClientProvider {
  public typealias T = DownloadCragInput
  public typealias R = DownloadCragResponse?

  public func call(
    _ data: DownloadCragInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> DownloadCragResponse? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Download_sol_crag_sol__lcub_id_rcub_(
          Operations.get_sol_api_sol_Download_sol_crag_sol__lcub_id_rcub_.Input(
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
        return nil

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "DownloadCragClient", errorHandler)
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
