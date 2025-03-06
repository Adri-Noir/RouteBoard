//
//  NonAuthenticatedClientProvider.swift
//  RouteBoard
//
//  Created with <3 on 05.01.2025..
//

import OpenAPIRuntime

public protocol NonAuthenticationProtocol {
  associatedtype T
  associatedtype R

  func call(_ data: T, _ errorHandler: ((_ message: String) -> Void)?) async -> R
  func cancel()
}

public class NonAuthenticatedProvider {
  private var _client = ClientPicker()
  private var _cachedClient: ClientWithSession?
  public var isCached: Bool

  public init(isCached: Bool = false) {
    self.isCached = isCached
  }

  public func getClient() -> ClientWithSession {
    _cachedClient = _client.getClient(token: nil)
    return _cachedClient!
  }

  public func cancelRequest() {
    _cachedClient?.session.invalidateAndCancel()
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
      let firstErrorDict = firstError as? [String: Any],
      let message = firstErrorDict["message"] as? String
    {
      return message
    }

    return returnUnknownError()
  }

  /// Handle bad request error case
  /// - Parameters:
  ///   - error: The error response with additional properties
  ///   - className: The name of the client class for logging purposes
  ///   - errorHandler: Optional error handler callback
  /// - Returns: Always returns nil to be used in a return statement
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

  /// Handle not found error case
  /// - Parameters:
  ///   - error: The error response with additional properties
  ///   - errorHandler: Optional error handler callback
  /// - Returns: Always returns nil to be used in a return statement
  public func handleNotFound(
    _ error: [String: OpenAPIRuntime.OpenAPIValueContainer]?,
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    if let error = error {
      errorHandler?(getErrorMessage(error))
    }
  }

  public func handleUnauthorized(
    _ error: [String: OpenAPIRuntime.OpenAPIValueContainer]?,
    _ errorHandler: ((_ message: String) -> Void)?
  ) {
    if let error = error {
      errorHandler?(getErrorMessage(error))
    } else {
      errorHandler?(returnUnknownError())
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

public typealias NonAuthenticatedClientProvider = NonAuthenticatedProvider
  & NonAuthenticationProtocol
