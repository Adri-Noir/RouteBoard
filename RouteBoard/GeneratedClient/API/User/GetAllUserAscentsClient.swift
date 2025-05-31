// Created with <3 on 31.05.2025.

import OpenAPIURLSession

public struct GetAllUserAscentsInput {
  public let profileUserId: String
  public let page: Int?
  public let pageSize: Int?

  public init(
    profileUserId: String,
    page: Int? = nil,
    pageSize: Int? = nil
  ) {
    self.profileUserId = profileUserId
    self.page = page
    self.pageSize = pageSize
  }
}

public typealias GetAllUserAscentsOutput = Components.Schemas.PaginatedUserAscentsDto

public class GetAllUserAscentsClient: AuthenticatedClientProvider {
  public typealias T = GetAllUserAscentsInput
  public typealias R = GetAllUserAscentsOutput?

  public func call(
    _ data: GetAllUserAscentsInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> GetAllUserAscentsOutput? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub__sol_ascents(
          Operations.get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub__sol_ascents.Input(
            path: Operations.get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub__sol_ascents
              .Input.Path(
                profileUserId: data.profileUserId
              ),
            query: Operations
              .get_sol_api_sol_User_sol_user_sol__lcub_profileUserId_rcub__sol_ascents.Input.Query(
                page: data.page.map { Int32($0) },
                pageSize: data.pageSize.map { Int32($0) }
              )
          )
        )

      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetAllUserAscentsClient", errorHandler)
        return nil
      case .notFound(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetAllUserAscentsClient", errorHandler)
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
