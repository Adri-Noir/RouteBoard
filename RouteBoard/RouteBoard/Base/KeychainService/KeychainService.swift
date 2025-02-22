//
//  KeychainService.swift
//  RouteBoard
//
//  Created with <3 on 04.01.2025..
//

import KeychainAccess

private let JWTTokenKey = "jwtToken"

public class KeychainService {

  private let keychain = Keychain(service: "com.Alpinity")

  public init() {
  }

  public func saveJWTToken(token: String) {
    do {
      #if targetEnvironment(simulator)
        print("Running in simulator - not saving token")
      #else
        try keychain.set(token, key: JWTTokenKey)
      #endif
    } catch {
      print(error)
    }
  }

  public func getJWTToken() -> String? {
    do {
      return try keychain.get(JWTTokenKey)
    } catch {
      print(error)
    }
    return nil
  }

  public func deleteJWTToken() {
    do {
      try keychain.remove(JWTTokenKey)
    } catch {
      print(error)
    }
  }
}
