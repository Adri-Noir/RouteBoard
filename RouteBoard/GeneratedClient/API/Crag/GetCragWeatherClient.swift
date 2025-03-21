// Created with <3 on 09.03.2025.

import OpenAPIURLSession

public typealias CragWeatherInput = Operations
  .get_sol_api_sol_Map_sol_weather_sol__lcub_cragId_rcub_.Input.Path
public typealias CragWeather = Components.Schemas.WeatherResponseDto

public class GetCragWeatherClient: AuthenticatedClientProvider {
  public typealias T = CragWeatherInput
  public typealias R = CragWeather?

  public func call(
    _ data: CragWeatherInput, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?
  ) async -> CragWeather? {
    do {
      let result = try await getClient(authData).client
        .get_sol_api_sol_Map_sol_weather_sol__lcub_cragId_rcub_(
          Operations.get_sol_api_sol_Map_sol_weather_sol__lcub_cragId_rcub_.Input(
            path: data))

      switch result {
      case let .ok(okResponse):
        switch okResponse.body {
        case .json(let value):
          return value
        }

      case .unauthorized(let error):
        await handleUnauthorize(
          try? error.body.json.additionalProperties, authData, errorHandler)

      case .badRequest(let error):
        handleBadRequest(
          try? error.body.json.additionalProperties, "GetCragWeatherClient", errorHandler)

      case .notFound(let error):
        handleNotFound(try? error.body.json.additionalProperties, errorHandler)

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
