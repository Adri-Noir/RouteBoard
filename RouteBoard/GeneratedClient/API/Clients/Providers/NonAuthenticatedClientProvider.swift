//
//  NonAuthenticatedClientProvider.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 05.01.2025..
//

public protocol NonAuthenticationProtocol {
  associatedtype T
  associatedtype R

  func call(_ data: T) async -> R
}

public class NonAuthenticatedProvider {
  private var _client = ClientPicker()

  public init() {
  }

  public func getClient() -> Client {
    return _client.getClient(token: nil)
  }
}

public typealias NonAuthenticatedClientProvider = NonAuthenticatedProvider
  & NonAuthenticationProtocol
