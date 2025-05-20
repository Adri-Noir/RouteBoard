// Created with <3 on 29.03.2025.

import Foundation

public typealias DetectRoutePhoto = Components.Schemas.DetectRoutePhotoDto

public class GetRouteDetectionPhotosClient: AuthenticatedClientProvider {
  public typealias T = String
  public typealias R = [DetectRoutePhoto]?

  public func call(_ data: T, _ authData: AuthData, _ errorHandler: ((String) -> Void)? = nil) async
    -> R
  {
    do {
      let result = try await getClient(authData).client.get_sol_routePhotos_sol__lcub_routeId_rcub_(
        Operations.get_sol_routePhotos_sol__lcub_routeId_rcub_.Input(path: .init(routeId: data)))

      switch result {
      case .ok(let okResponse):
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
          try? error.body.application_problem_plus_json, "GetRouteDetectionPhotosClient",
          errorHandler)
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
