// Created with <3 on 21.02.2025.

import SwiftUI

struct UserLoginView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var errorMessage: String = ""
  @State private var showErrorAlert: Bool = false
  @State private var headerVisibleRatio: CGFloat = 1

  @FocusState private var isEmailFocused: Bool
  @FocusState private var isPasswordFocused: Bool

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

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
      ScrollViewWithStickyHeader(
        header: {
          headerView
            .padding(.top, 20)
            .background(Color.newBackgroundGray)
        },
        headerOverlay: {
          ZStack {
            HStack {
              backButtonView
              Spacer()
            }
            Text("Login")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(Color.newPrimaryColor)
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .padding(.top, safeAreaInsets.top)
          .padding(.bottom, 12)
          .background(Color.newBackgroundGray)
          .opacity(headerVisibleRatio == 0 ? 1 : 0)
          .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
        },
        headerHeight: safeAreaInsets.top + 20,
        onScroll: { _, headerVisibleRatio in
          self.headerVisibleRatio = headerVisibleRatio
        }
      ) {
        VStack(alignment: .leading, spacing: 20) {
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
        .padding(.bottom, safeAreaInsets.bottom)
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

  private var backButtonView: some View {
    Button(action: {
      dismiss()
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(.newPrimaryColor)
    }
  }

  private var headerView: some View {
    VStack {
      Spacer()
      HStack(alignment: .center) {
        backButtonView
        Text("Login")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(.newPrimaryColor)
        Spacer()
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.top, 20)
  }
}

#Preview {
  AuthInjectionMock {
    UserLoginView()
  }
}
