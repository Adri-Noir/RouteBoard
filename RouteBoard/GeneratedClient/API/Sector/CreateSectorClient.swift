// Created with <3 on 03.04.2025.

import OpenAPIURLSession

// Define the output type - assuming this exists based on CragDetailedDto pattern
public typealias CreateSectorCommand = Components.Schemas.CreateSectorCommand
public typealias CreateSectorOutput = Components.Schemas.SectorDetailedDto

public class CreateSectorClient: AuthenticatedClientProvider {
  public typealias T = CreateSectorCommand
  public typealias R = CreateSectorOutput?

  public func call(
    _ data: CreateSectorCommand, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CreateSectorOutput? {
    do {
      let result = try await getClient(authData).client.post_sol_api_sol_Sector(
        Operations.post_sol_api_sol_Sector.Input(body: .json(data)))

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
          try? error.body.application_problem_plus_json, "CreateSectorClient", errorHandler)

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
