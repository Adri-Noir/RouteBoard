//
//  LoginView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.01.2025..
//

import GeneratedClient
import SwiftUI

struct LoginView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var isLoginFailed: Bool = false
  @State private var isLoginSuccess: Bool = false
  @EnvironmentObject var authViewModel: AuthViewModel

  func login() async {
    isLoading = true

    do {
      try await authViewModel.login(emailOrUsername: email, password: password)
    } catch {
      isLoginFailed = true
      isLoading = false
      return
    }

    isLoading = false
    isLoginSuccess = true
  }

  var body: some View {
    NavigationStack {
      ApplyBackgroundColor {
        VStack {
          Text("Welcome to Alpinity")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundStyle(.black)
            .padding()

          if authViewModel.user != nil {
            Text(authViewModel.user?.username ?? "")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundStyle(.black)
              .padding()
          }

          TextField("Username or email", text: $email)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color.backgroundGray)
            .cornerRadius(10)
            .padding()

          SecureField("Password", text: $password)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color.backgroundGray)
            .cornerRadius(10)
            .padding()

          Button {
            Task(priority: .userInitiated) {
              await login()
            }
          } label: {
            Text("Login")
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.primaryColor)
              .cornerRadius(10)
          }
          .padding()

          if isLoading {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
              .padding()
          }

          if isLoginFailed {
            Text("Login failed")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundStyle(.red)
              .padding()
          }
        }
        .padding()
      }
    }
  }
}

#Preview {
  AuthInjection {
    LoginView()
  }
}
