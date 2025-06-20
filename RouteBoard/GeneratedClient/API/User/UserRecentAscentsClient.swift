// Created with <3 on 02.03.2025.

import OpenAPIURLSession

public typealias UserRecentAscents = Components.Schemas.RecentlyAscendedRouteDto

public class UserRecentAscentsClient: AuthenticatedClientProvider {
  public typealias T = Void
  public typealias R = [UserRecentAscents]

  public func call(
    _ data: Void, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> [UserRecentAscents] {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_User_sol_recentlyAscendedRoutes()
      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "UserRecentAscentsClient", errorHandler)
        return []
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return []
      case .undocumented:
        handleUndocumented(errorHandler)
        return []
      }
    } catch {
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return []
  }

  public func cancel() {
    cancelRequest()
  }
}
