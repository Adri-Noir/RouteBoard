// Created with <3 on 28.05.2025.

import OpenAPIURLSession

public struct EditUserInput {
  public let username: String?
  public let email: String?
  public let firstName: String?
  public let lastName: String?
  public let dateOfBirth: Date?
  public let password: String?

  public init(
    username: String? = nil,
    email: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    dateOfBirth: Date? = nil,
    password: String? = nil
  ) {
    self.username = username
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.dateOfBirth = dateOfBirth
    self.password = password
  }
}

public typealias EditUserOutput = Components.Schemas.UserProfileDto

public class EditUserClient: AuthenticatedClientProvider {
  public typealias T = EditUserInput
  public typealias R = EditUserOutput?

  public func call(
    _ data: EditUserInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> EditUserOutput? {
    do {
      let result = try await getClient(authData).client
        .put_sol_api_sol_User_sol_edit(
          Operations.put_sol_api_sol_User_sol_edit.Input(
            body: .json(
              Components.Schemas.EditUserCommand(
                username: data.username,
                email: data.email,
                firstName: data.firstName,
                lastName: data.lastName,
                dateOfBirth: data.dateOfBirth,
                password: data.password
              ))
          )
        )

      switch result {
      case .ok(let response):
        return try response.body.json
      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "EditUserClient", errorHandler)
        return nil
      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)
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
