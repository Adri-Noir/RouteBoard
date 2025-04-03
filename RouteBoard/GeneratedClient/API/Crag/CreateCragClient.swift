// Created with <3 on 31.03.2025.

import OpenAPIURLSession

public typealias CreateCragInput = Components.Schemas.CreateCragCommand
public typealias CreateCragOutput = Components.Schemas.CragDetailedDto

public class CreateCragClient: AuthenticatedClientProvider {
  public typealias T = CreateCragInput
  public typealias R = CreateCragOutput?

  public func call(
    _ data: CreateCragInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CreateCragOutput? {
    do {
      let result = try await getClient(authData).client.post_sol_api_sol_Crag(
        Operations.post_sol_api_sol_Crag.Input(
          body: .json(data)))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.application_problem_plus_json, authData, errorHandler)

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.application_problem_plus_json, "CreateCragClient", errorHandler)

      case .notFound(let error):
        handleNotFound(try? error.body.application_problem_plus_json, errorHandler)

      case .undocumented:
        handleUndocumented(errorHandler)
        return nil
      }
    } catch (let error) {
      print(error)
      // removed because cancelling the request will trigger this error
      // errorHandler?(returnUnknownError())
    }

    return nil
  }

  public func cancel() {
    cancelRequest()
  }
}
