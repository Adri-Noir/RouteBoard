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
  public let role: UserRole
  public let firstName: String
  public let lastName: String
  public let dateOfBirth: Date
  public let profilePhoto: String
}

public class AuthViewModel: ObservableObject {
  @Published var user: UserModel?

  private let keychainService = KeychainService()
  private let loginClient = LoginClient()
  private let meClient = MeClient()
  private let authenticationCheckerClient = AuthenticationCheckerClient()

  public init() {}

  public func loginWithSeededUser() async {
    guard
      let loggedInUser = await loginClient.call(
        LoginInput(emailOrUsername: "seededUser", password: "testpassword"))
    else {
      print("Failed to login with seeded user")
      return
    }

    try? await self.saveUser(loggedInUser)
  }

  func saveUser(_ loggedInUser: LoggedInUser) async throws {
    guard let token = loggedInUser.token,
      let email = loggedInUser.email,
      let username = loggedInUser.username,
      let role = loggedInUser.role
    else {
      throw AuthError.loginFailed
    }

    keychainService.saveJWTToken(token: token)
    await MainActor.run {
      withAnimation {
        user = UserModel(
          id: loggedInUser.id, email: email, username: username, token: token, role: role,
          firstName: loggedInUser.firstName ?? "", lastName: loggedInUser.lastName ?? "",
          dateOfBirth: loggedInUser.dateOfBirth ?? Date(),
          profilePhoto: loggedInUser.profilePhoto?.url ?? "")
      }
    }
  }

  func login(emailOrUsername: String, password: String) async throws {
    guard
      let loggedInUser = await loginClient.call(
        LoginInput(emailOrUsername: emailOrUsername, password: password))
    else {
      throw AuthError.loginFailed
    }

    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 500_000_000)
      try? await self.saveUser(loggedInUser)
    }
  }

  func logout() async {
    keychainService.deleteJWTToken()
    await MainActor.run {
      user = nil
    }
  }

  func loadUserModel(refresh: Bool = false) async {
    if user != nil && !refresh {
      return
    }

    let keychainToken = keychainService.getJWTToken()

    guard let keychainToken = keychainToken else {
      await self.logout()
      return
    }

    guard
      let loggedInUser = await meClient.call(
        (), AuthData(token: keychainToken, unauthorizedHandler: self.logout))
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

  func getTemperatureConverter() -> TemperatureConverterProtocol {
    return CelsiusTemperatureConverter()
  }

  func cancelRequests() {
    loginClient.cancelRequest()
    meClient.cancelRequest()
    authenticationCheckerClient.cancelRequest()
  }

  var isCreator: Bool {
    return user?.role == UserRole.Creator || user?.role == UserRole.Admin
  }

  var isAdmin: Bool {
    return user?.role == UserRole.Admin
  }
}
