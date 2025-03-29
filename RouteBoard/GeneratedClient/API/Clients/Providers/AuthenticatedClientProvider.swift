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

public protocol AuthenticationClientProtocol {
  associatedtype T
  associatedtype R

  func call(_ data: T, _ authData: AuthData, _ errorHandler: ((_ message: String) -> Void)?) async
    -> R
  func cancel()
}

public class AuthenticationProvider {
  private var _client = ClientPicker()
  private var _cachedClient: ClientWithSession?

  public init() {}

  deinit {
    cancelRequest()
  }

  private func validateToken(_ token: String?) throws -> String {
    guard let token = token else {
      throw AuthClientProviderError.noTokenProvided
    }

    return token
  }

  public func getClient(_ authData: AuthData) -> ClientWithSession {
    _cachedClient = _client.getClient(token: authData.token)
    return _cachedClient!
  }

  public func cancelRequest() {
    _cachedClient?.session.invalidateAndCancel()
  }

  public func returnUnauthorized() -> String {
    return "Unauthorized"
  }

  public func returnUnknownError() -> String {
    return "Unknown error occurred!"
  }

  public func logBadRequest(_ className: String) {
    print("\(className): Bad request")
  }

  public func getErrorMessage(_ error: [String: OpenAPIRuntime.OpenAPIValueContainer]) -> String {
    if let errorsContainer = error["errors"],
      let errorsArray = errorsContainer.value as? [[String: Any]],
      let firstError = errorsArray.first,
      let message = firstError["message"] as? String
    {
      return message
    }

    return returnUnknownError()
  }

  /// Handle unauthorized error case
  /// - Parameters:
  ///   - error: The error response with additional properties
  ///   - authData: Authentication data containing token and unauthorized handler
  ///   - errorHandler: Optional error handler callback
  public func handleUnauthorize(
    _ error: [String: OpenAPIRuntime.OpenAPIValueContainer]?,
    _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)?
  ) async {
    if let error = error {
      errorHandler?(getErrorMessage(error))
    } else {
      errorHandler?(returnUnauthorized())
    }
    await authData.unauthorizedHandler?()
  }

  /// Handle bad request error case
  /// - Parameters:
  ///   - error: The error response with additional properties
  ///   - className: The name of the client class for logging purposes
  ///   - errorHandler: Optional error handler callback
  public func handleBadRequest(
    _ error: [String: OpenAPIRuntime.OpenAPIValueContainer]?,
    _ className: String,
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    if let error = error {
      errorHandler?(getErrorMessage(error))
    } else {
      errorHandler?(returnUnknownError())
    }
    logBadRequest(className)
  }

  public func handleBadRequestString(
    _ error: String,
    _ className: String,
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    errorHandler?(error)
    logBadRequest(className)
  }

  /// Handle not found error case
  /// - Parameters:
  ///   - error: The error response with additional properties
  ///   - errorHandler: Optional error handler callback
  public func handleNotFound(
    _ error: [String: OpenAPIRuntime.OpenAPIValueContainer]?,
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    if let error = error {
      errorHandler?(getErrorMessage(error))
    }
  }

  /// Handle undocumented error case
  /// - Parameter errorHandler: Optional error handler callback
  /// - Returns: Always returns nil to be used in a return statement
  public func handleUndocumented(
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    errorHandler?(returnUnknownError())
  }
}

public typealias AuthenticatedClientProvider = AuthenticationProvider
  & AuthenticationClientProtocol
