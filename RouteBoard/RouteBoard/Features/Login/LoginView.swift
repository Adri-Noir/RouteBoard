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

          TextField("", text: $email, prompt: Text("Username or email").foregroundStyle(.gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color.backgroundGray)
            .foregroundColor(.black)
            .cornerRadius(10)
            .padding()

          SecureField("Password", text: $password, prompt: Text("Password").foregroundStyle(.gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color.backgroundGray)
            .foregroundColor(.black)
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
            Text("Incorrect username or password")
              .font(.title3)
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
