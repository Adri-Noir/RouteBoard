// Created with <3 on 29.05.2025.

import OpenAPIURLSession

public struct GetAllUsersInput {
  public let page: Int?
  public let pageSize: Int?
  public let search: String?

  public init(
    page: Int? = nil,
    pageSize: Int? = nil,
    search: String? = nil
  ) {
    self.page = page
    self.pageSize = pageSize
    self.search = search
  }
}

public typealias GetAllUsersOutput = Components.Schemas.PaginatedUsersDto

public class GetAllUsersClient: AuthenticatedClientProvider {
  public typealias T = GetAllUsersInput
  public typealias R = GetAllUsersOutput?

  public func call(
    _ data: GetAllUsersInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> GetAllUsersOutput? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_User_sol_all(
          Operations.get_sol_api_sol_User_sol_all.Input(
            query: Operations.get_sol_api_sol_User_sol_all.Input.Query(
              page: data.page.map { Int32($0) },
              pageSize: data.pageSize.map { Int32($0) },
              search: data.search
            )
          )
        )

      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetAllUsersClient", errorHandler)
        return nil
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
        return nil
      case .forbidden(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "GetAllUsersClient", errorHandler)
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
