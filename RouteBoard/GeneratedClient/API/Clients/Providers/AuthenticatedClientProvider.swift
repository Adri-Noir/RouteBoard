//
//  AuthenticatedClientProvider.swift
//  RouteBoard
//
//  Created with <3 on 05.01.2025..
//

import OpenAPIRuntime

struct ErrorResponse: Codable {
  let statusCode: Int
  let message: String
}

public enum AuthClientProviderError: Error {
  case noTokenProvided
}

public struct AuthData {
  var token: String?
  var unauthorizedHandler: (() async -> Void)?

  public init(token: String?, unauthorizedHandler: (() async -> Void)?) {
    self.token = token
    self.unauthorizedHandler = unauthorizedHandler
  }
}

public protocol AuthenticationProtocol {
  associatedtype T
  associatedtype R

  func call(_ data: T, _ authData: AuthData) async -> R
}

public class AuthenticationProvider {
  private var _client = ClientPicker()

  public init() {}

  private func validateToken(_ token: String?) throws -> String {
    guard let token = token else {
      throw AuthClientProviderError.noTokenProvided
    }

    return token
  }

  public func getClient(_ authData: AuthData) -> Client {
    return _client.getClient(token: authData.token)
  }

  public func returnUnauthorized() -> String {
    return "Unauthorized"
  }

  public func returnUnknownError() -> String {
    return "Unknown error occurred!"
  }

  public func getErrorMessage(_ error: [String: OpenAPIRuntime.OpenAPIValueContainer]) -> String {
    if let errorsContainer = error["errors"],
      let errorsArray = errorsContainer.value as? [[String: Any]],
      let firstError = errorsArray.first,
      let firstErrorDict = firstError as? [String: Any],
      let message = firstErrorDict["message"] as? String
    {
      return message
    }

    return returnUnknownError()
  }
}

public typealias AuthenticatedClientProvider = AuthenticationProvider
  & AuthenticationProtocol
