//
//  AuthenticatedClientProvider.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 05.01.2025..
//

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
}

public typealias AuthenticatedClientProvider = AuthenticationProvider
  & AuthenticationProtocol
