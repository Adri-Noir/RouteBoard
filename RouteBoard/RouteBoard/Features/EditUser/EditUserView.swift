// Created with <3 on 28.05.2025.

import GeneratedClient
import SwiftUI
import UIKit

struct EditUserView: View {
  @State private var firstName: String = ""
  @State private var lastName: String = ""
  @State private var username: String = ""
  @State private var dateOfBirth: Date = Date()
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var errorMessage: String = ""
  @State private var showErrorAlert: Bool = false
  @State private var profilePhoto: [UIImage] = []
  @State private var headerVisibleRatio: CGFloat = 1
  @State private var showPhotoOnly: Bool = false
  @State private var selectedPhoto: UIImage? = nil
  @State private var isPhotoLoading: Bool = false

  @FocusState private var isFirstNameFocused: Bool
  @FocusState private var isLastNameFocused: Bool
  @FocusState private var isUsernameFocused: Bool
  @FocusState private var isEmailFocused: Bool
  @FocusState private var isPasswordFocused: Bool

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let editUserClient = EditUserClient()
  private let editUserPictureClient = EditUserPictureClient()

  private var isFormValid: Bool {
    !firstName.isEmpty || !lastName.isEmpty || !username.isEmpty || !email.isEmpty
      || !password.isEmpty
  }

  private var hasChanges: Bool {
    guard let user = authViewModel.user else { return false }

    // Check if any field has changed from the original values
    if firstName != user.firstName { return true }
    if lastName != user.lastName { return true }
    if username != user.username { return true }
    if email != user.email { return true }
    if !password.isEmpty { return true }
    if !profilePhoto.isEmpty { return true }

    return false
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  func updateProfile() async {
    guard hasChanges else {
      errorMessage = "No changes to save"
      showErrorAlert = true
      return
    }

    isLoading = true
    defer { isLoading = false }

    // Only include fields that have values and are different from current user data
    let editInput = EditUserInput(
      username: username.isEmpty ? nil : username,
      email: email.isEmpty ? nil : email,
      firstName: firstName.isEmpty ? nil : firstName,
      lastName: lastName.isEmpty ? nil : lastName,
      dateOfBirth: dateOfBirth,
      password: password.isEmpty ? nil : password
    )

    let errorHandler: (String) -> Void = { errorMsg in
      self.errorMessage = errorMsg
      self.showErrorAlert = true
    }

    if await editUserClient.call(editInput, authViewModel.getAuthData(), errorHandler) != nil {
      dismiss()
    } else {
      if errorMessage.isEmpty {
        errorMessage = "Profile update failed"
        showErrorAlert = true
      }
    }

  }

  func updateProfilePhoto() async {
    guard let photo = selectedPhoto,
      let photoData = photo.jpegData(compressionQuality: 0.8),
      let userId = authViewModel.user?.id
    else {
      errorMessage = "No photo selected or user not found"
      showErrorAlert = true
      return
    }

    isPhotoLoading = true
    defer { isPhotoLoading = false }

    let editPictureInput = EditUserPictureInput(userId: userId, photo: photoData)

    let errorHandler: (String) -> Void = { errorMsg in
      self.errorMessage = errorMsg
      self.showErrorAlert = true
    }

    if await editUserPictureClient.call(
      editPictureInput, authViewModel.getAuthData(), errorHandler) != nil
    {
      // Clear the selected photo and reset state
      selectedPhoto = nil
      profilePhoto = []
    } else {
      if errorMessage.isEmpty {
        errorMessage = "Photo update failed"
        showErrorAlert = true
      }
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
            Text("Edit Profile")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(Color.newPrimaryColor)
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
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
        if !showPhotoOnly {
          // Profile Information Form
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
              .padding(.horizontal, ThemeExtension.horizontalPadding)

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
              .padding(.horizontal, ThemeExtension.horizontalPadding)

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
              .padding(.horizontal, ThemeExtension.horizontalPadding)

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
            .padding(.horizontal, ThemeExtension.horizontalPadding)

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
              .padding(.horizontal, ThemeExtension.horizontalPadding)

            SecureField(
              "", text: $password,
              prompt: Text("New Password (leave empty to keep current)").foregroundColor(.gray)
            )
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
            .submitLabel(.done)
            .focused($isPasswordFocused)
            .onSubmit {
              Task {
                await updateProfile()
              }
            }
            .padding(.horizontal, ThemeExtension.horizontalPadding)

            // Photo Edit Button
            HStack {
              Spacer()
              Button(action: {
                showPhotoOnly = true
              }) {
                HStack {
                  Image(systemName: "camera")
                    .foregroundColor(.white)
                  Text("Edit Photo")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.newPrimaryColor.opacity(0.8))
                .cornerRadius(10)
                .frame(width: 200)
              }
              Spacer()
            }

            // Update Profile Button
            HStack {
              Spacer()
              Button(action: {
                Task {
                  await updateProfile()
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
                  Text("Update Profile")
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
              .disabled(!hasChanges)
              .opacity(hasChanges ? 1.0 : 0.6)
              Spacer()
            }
          }
          .padding(.top, 20)
          .padding(.bottom, safeAreaInsets.bottom)
        } else {
          // Photo Only View
          VStack(alignment: .leading, spacing: 20) {
            HStack {
              Button(action: {
                showPhotoOnly = false
              }) {
                HStack {
                  Image(systemName: "chevron.left")
                    .foregroundColor(.newPrimaryColor)
                  Text("Back to Profile")
                    .foregroundColor(.newPrimaryColor)
                }
              }
              Spacer()
            }
            .padding(.horizontal, ThemeExtension.horizontalPadding)

            VStack(spacing: 20) {
              // Current Photo Display
              if let currentPhotoUrl = authViewModel.user?.profilePhoto {
                VStack(spacing: 8) {
                  AsyncImage(url: URL(string: currentPhotoUrl)) { image in
                    image
                      .resizable()
                      .scaledToFill()
                  } placeholder: {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .scaledToFit()
                      .foregroundColor(.gray)
                  }
                  .frame(width: 120, height: 120)
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))

                  Text("Current Photo")
                    .font(.caption)
                    .foregroundColor(.gray)
                }
              }

              // Photo Preview
              if let selectedPhoto = selectedPhoto {
                VStack(spacing: 8) {
                  Image(uiImage: selectedPhoto)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.newPrimaryColor, lineWidth: 2))

                  Text("New Photo Preview")
                    .font(.caption)
                    .foregroundColor(.newPrimaryColor)
                }
              }

              // Photo Selection
              PhotoPickerField(
                title: "Profile Photo",
                selectedImages: $profilePhoto,
                singleMode: true
              )
              .onChange(of: profilePhoto) { _, newPhotos in
                selectedPhoto = newPhotos.first
              }

              // Upload Button
              if selectedPhoto != nil {
                HStack {
                  Spacer()
                  Button(action: {
                    Task {
                      await updateProfilePhoto()
                    }
                  }) {
                    if isPhotoLoading {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.newPrimaryColor)
                        .cornerRadius(10)
                        .frame(width: 200)
                    } else {
                      Text("Update Photo")
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
                  .disabled(isPhotoLoading)
                  Spacer()
                }
              }
            }
            .padding(.horizontal, ThemeExtension.horizontalPadding)
          }
          .padding(.top, 20)
          .padding(.bottom, safeAreaInsets.bottom)
        }
      }
      .background(Color.newBackgroundGray)
      .padding(.top, 1)
      .alert("Profile Update Error", isPresented: $showErrorAlert) {
        Button("OK") {
          errorMessage = ""
        }
      } message: {
        Text(errorMessage)
      }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear {
      if let user = authViewModel.user {
        username = user.username
        email = user.email
        firstName = user.firstName
        lastName = user.lastName
        dateOfBirth = user.dateOfBirth
      }
    }
    .onDisappear {
      editUserClient.cancel()
      editUserPictureClient.cancel()
    }
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
      HStack {
        backButtonView
        Text("Edit Profile")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(.newPrimaryColor)
        Spacer()
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .padding(.top, 20)
    }
  }
}

#Preview {
  AuthInjectionMock {
    EditUserView()
  }
}
