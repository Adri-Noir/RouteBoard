//
//  KeychainService.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.01.2025..
//

import KeychainAccess

private let JWTTokenKey = "jwtToken"

public class KeychainService {

  private let keychain = Keychain(service: "com.Alpinity")

  public init() {
  }

  public func saveJWTToken(token: String) {
    do {
      try keychain.set(token, key: JWTTokenKey)
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
