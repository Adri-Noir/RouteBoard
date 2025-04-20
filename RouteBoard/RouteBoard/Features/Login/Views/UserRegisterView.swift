// Created with <3 on 07.04.2025.

import GeneratedClient
import SwiftUI
import UIKit

struct UserRegisterView: View {
  @State private var firstName: String = ""
  @State private var lastName: String = ""
  @State private var username: String = ""
  @State private var dateOfBirth: Date = Date()
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""
  @State private var isLoading: Bool = false
  @State private var errorMessage: String = ""
  @State private var showErrorAlert: Bool = false
  @State private var profilePhoto: [UIImage] = []
  @State private var headerVisibleRatio: CGFloat = 1

  @FocusState private var isFirstNameFocused: Bool
  @FocusState private var isLastNameFocused: Bool
  @FocusState private var isUsernameFocused: Bool
  @FocusState private var isEmailFocused: Bool
  @FocusState private var isPasswordFocused: Bool
  @FocusState private var isConfirmPasswordFocused: Bool

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let registerClient = RegisterClient()

  private var isFormValid: Bool {
    !firstName.isEmpty && !lastName.isEmpty && !username.isEmpty && !email.isEmpty
      && !password.isEmpty && password == confirmPassword
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  func register() async {
    guard isFormValid else {
      errorMessage = "Please fill all fields and ensure passwords match"
      showErrorAlert = true
      return
    }

    isLoading = true

    do {
      // Convert profilePhoto to Data if available
      let profilePhotoData = profilePhoto.first?.jpegData(compressionQuality: 0.8)

      let registerInput = RegisterInput(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        profilePhoto: profilePhotoData
      )

      let errorHandler: (String) -> Void = { errorMsg in
        self.errorMessage = errorMsg
        self.showErrorAlert = true
      }

      if let user = await registerClient.call(registerInput, errorHandler) {
        try await authViewModel.saveUser(user)
        isLoading = false
        dismiss()
      } else {
        if errorMessage.isEmpty {
          errorMessage = "Registration failed"
          showErrorAlert = true
        }
        isLoading = false
      }
    } catch {
      isLoading = false
      errorMessage = "Registration failed: \(error.localizedDescription)"
      showErrorAlert = true
    }
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollViewWithStickyHeader(
        header: {
          headerView
            .padding(.bottom, 12)
            .background(Color.newBackgroundGray)
        },
        headerOverlay: {
          HStack {
            backButtonView
            Spacer()
            Text("Register")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(Color.newPrimaryColor)
            Spacer()
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .padding(.top, safeAreaInsets.top)
          .padding(.bottom, 12)
          .background(Color.newBackgroundGray)
          .opacity(headerVisibleRatio == 0 ? 1 : 0)
          .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
        },
        headerHeight: safeAreaInsets.top,
        onScroll: { _, headerVisibleRatio in
          self.headerVisibleRatio = headerVisibleRatio
        }
      ) {
        VStack(alignment: .leading, spacing: 20) {
          TextField("", text: $firstName, prompt: Text("First Name").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textContentType(.givenName)
            .submitLabel(.next)
            .focused($isFirstNameFocused)
            .onSubmit {
              isLastNameFocused = true
            }
          TextField("", text: $lastName, prompt: Text("Last Name").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textContentType(.familyName)
            .submitLabel(.next)
            .focused($isLastNameFocused)
            .onSubmit {
              isUsernameFocused = true
            }
          TextField("", text: $username, prompt: Text("Username").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.username)
            .submitLabel(.next)
            .focused($isUsernameFocused)
            .onSubmit {
              isEmailFocused = true
            }
          DatePicker(
            selection: $dateOfBirth,
            displayedComponents: .date
          ) {
            Text("Date of Birth")
              .foregroundColor(.gray)
          }
          .colorScheme(.light)
          .foregroundStyle(Color.newTextColor)
          .accentColor(Color.newPrimaryColor)
          .padding()
          .background(Color.white)
          .cornerRadius(10)
          .onSubmit {
            isEmailFocused = true
          }
          TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray))
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
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
            .textContentType(.newPassword)
            .submitLabel(.next)
            .focused($isPasswordFocused)
            .onSubmit {
              isConfirmPasswordFocused = true
            }
          SecureField(
            "", text: $confirmPassword, prompt: Text("Confirm Password").foregroundColor(.gray)
          )
          .foregroundColor(.black)
          .padding()
          .background(Color.white)
          .cornerRadius(10)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .submitLabel(.done)
          .focused($isConfirmPasswordFocused)
          .onSubmit {
            Task {
              await register()
            }
          }
          PhotoPickerField(title: "Profile Photo", selectedImages: $profilePhoto, singleMode: true)
          HStack {
            Spacer()
            Button(action: {
              Task {
                await register()
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
                Text("Register")
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
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            Spacer()
          }
        }
        .padding(.bottom, safeAreaInsets.bottom)
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
      .background(Color.newBackgroundGray)
      .padding(.top, 1)
      .alert("Registration Error", isPresented: $showErrorAlert) {
        Button("OK") {
          errorMessage = ""
        }
      } message: {
        Text(errorMessage)
      }
    }
    .navigationBarBackButtonHidden(true)
    .onDisappear {
      registerClient.cancel()
    }
  }

  private var backButtonView: some View {
    Button(action: {
      dismiss()
    }) {
      Image(systemName: "arrow.left")
        .foregroundColor(.newPrimaryColor)
        .imageScale(.large)
    }
  }

  private var headerView: some View {
    HStack {
      backButtonView
      Text("Register")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(.newPrimaryColor)
        .padding(.bottom, 20)
      Spacer()
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.top, 20)
  }
}

#Preview {
  AuthInjectionMock {
    UserRegisterView()
  }
}
