//
//  AuthModel.swift
//  RouteBoard
//
//  Created with <3 on 04.01.2025..
//

import GeneratedClient
import SwiftUI

public enum AuthError: Error {
  case loginFailed
}

public struct UserModel: Codable {
  public let id: String
  public let email: String
  public let username: String
  public let token: String
}

public class AuthViewModel: ObservableObject {
  @Published var user: UserModel?

  private let keychainService = KeychainService()
  private let loginClient = LoginClient()
  private let meClient = MeClient()
  private let authenticationCheckerClient = AuthenticationCheckerClient()

  public init() {}

  public func loginWithSeededUser() async {
    do {
      try await login(emailOrUsername: "seededUser", password: "testpassword")
      print("Successfully logged in with seeded user")
    } catch {
      print("Failed to login with seeded user")
    }
  }

  private func saveUser(_ loggedInUser: LoggedInUser) async throws {
    guard let token = loggedInUser.token else {
      throw AuthError.loginFailed
    }
    guard let email = loggedInUser.email else {
      throw AuthError.loginFailed
    }
    guard let username = loggedInUser.username else {
      throw AuthError.loginFailed
    }

    keychainService.saveJWTToken(token: token)
    await MainActor.run {
      user = UserModel(id: loggedInUser.id, email: email, username: username, token: token)
    }
  }

  func login(emailOrUsername: String, password: String) async throws {
    guard
      let loggedInUser = await loginClient.call(
        LoginInput(emailOrUsername: emailOrUsername, password: password))
    else {
      throw AuthError.loginFailed
    }

    try await saveUser(loggedInUser)
  }

  func logout() async {
    keychainService.deleteJWTToken()
    await MainActor.run {
      user = nil
    }
  }

  func loadUserModel() async {
    if user != nil {
      return
    }

    let keychainToken = keychainService.getJWTToken()

    guard let keychainToken = keychainToken else {
      await self.logout()
      return
    }

    guard
      let loggedInUser = await meClient.call(
        nil, AuthData(token: keychainToken, unauthorizedHandler: self.logout))
    else {
      await self.logout()
      return
    }

    do {
      try await self.saveUser(loggedInUser)
    } catch {
      await self.logout()
    }

    return
  }

  func checkIfUserIsLoggedIn() async {
    if user?.token == nil {
      return
    }

    let results = await authenticationCheckerClient.call(nil, self.getAuthData())

    if !results {
      await MainActor.run {
        user = nil
      }
    }
  }

  func getAuthData() -> AuthData {
    return AuthData(token: user?.token, unauthorizedHandler: self.logout)
  }

  func getGradeSystem() -> ClimbingGrades {
    // TODO: Implement user's grade system
    return FrenchClimbingGrades()
  }
}
