// Created with <3 on 21.02.2025.

import SwiftUI

struct UserLoginView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var errorMessage: String = ""
  @State private var showErrorAlert: Bool = false

  @FocusState private var isEmailFocused: Bool
  @FocusState private var isPasswordFocused: Bool

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  func login() async {
    isLoading = true

    do {
      try await authViewModel.login(emailOrUsername: email, password: password)
      isLoading = false
      dismiss()
    } catch {
      isLoading = false
      errorMessage = "Invalid username or password"
      showErrorAlert = true
    }
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          HStack {
            Button(action: {
              dismiss()
            }) {
              Image(systemName: "arrow.left")
                .foregroundColor(.newPrimaryColor)
                .imageScale(.large)
            }
            Spacer()
          }

          Text("Login")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.newPrimaryColor)
            .padding(.bottom, 20)

          TextField("", text: $email, prompt: Text("Username or Email").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.username)
            .submitLabel(.next)
            .focused($isEmailFocused)
            .onSubmit {
              isPasswordFocused = true
            }

          SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.password)
            .submitLabel(.done)
            .focused($isPasswordFocused)
            .onSubmit {
              Task {
                await login()
              }
            }

          HStack {
            Spacer()
            Button(action: {
              Task {
                await login()
              }
            }) {
              if isLoading {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.newPrimaryColor)
                  .cornerRadius(10)
                  .frame(width: 200)
              } else {
                Text("Login")
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.newPrimaryColor)
                  .cornerRadius(10)
                  .foregroundColor(.white)
                  .fontWeight(.bold)
                  .font(.title3)
                  .frame(width: 200)
              }
            }
            Spacer()
          }
        }
        .padding(.top, 20)
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
      .background(Color.newBackgroundGray)
      .alert("Login failed", isPresented: $showErrorAlert) {
        Button("OK") {
          errorMessage = ""
        }
      } message: {
        Text(errorMessage)
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
  AuthInjectionMock {
    UserLoginView()
  }
}
