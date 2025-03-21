// Created with <3 on 05.03.2025.

import OpenAPIURLSession

public typealias UserProfile = Components.Schemas.UserProfileDto
public typealias UserProfileInput = Operations
  .get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub_.Input.Path

public class GetUserProfileClient: AuthenticatedClientProvider {
  public typealias T = UserProfileInput
  public typealias R = UserProfile?

  public func call(
    _ data: UserProfileInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> UserProfile? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub_(
          Operations.get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub_.Input(
            path: data))

      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GetUserProfileClient", errorHandler)
        return nil
      case .unauthorized(let error):
        await handleUnauthorize(try? error.body.json.additionalProperties, authData, errorHandler)
        return nil
      case .notFound(let error):
        handleNotFound(try? error.body.json.additionalProperties, errorHandler)
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
