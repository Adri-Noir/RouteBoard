import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthenticationMiddleware {

  /// The value for the `Authorization` header field.
  private let token: String?

  /// Creates a new middleware.
  /// - Parameter value: The value for the `Authorization` header field.
  init(value: String?) { self.token = value }
}

extension AuthenticationMiddleware: ClientMiddleware {
  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    // Adds the `Authorization` header field with the provided value.
    if token != nil {
      request.headerFields[.authorization] = "Bearer \(token!)"
    }
    return try await next(request, body, baseURL)
  }
}
