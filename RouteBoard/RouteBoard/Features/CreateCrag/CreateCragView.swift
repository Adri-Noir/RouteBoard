// Created with <3 on 31.03.2025.

import GeneratedClient
import MapKit
import PhotosUI
import SwiftUI

struct CreateCragView: View {
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var isSubmitting: Bool = false
  @State private var errorMessage: String? = nil
  @State private var selectedImages: [UIImage] = []

  // Track the crag ID and photo upload status
  @State private var createdCragId: String? = nil
  @State private var photoUploadStatus: [Int: PhotoUploadStatus] = [:]
  @State private var isUploadingPhotos: Bool = false
  @State private var activeUploads: Int = 0

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var navigationManager: NavigationManager

  private let createCragClient = CreateCragClient()
  // Remove the single uploadCragPhotoClient instance as we'll create one per upload

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          headerView

          InputField(
            title: "Crag Name",
            text: $name,
            placeholder: "Enter crag name here..."
          )

          TextAreaField(
            title: "Description",
            text: $description,
            placeholder: "Enter crag description here... (optional)"
          )

          PhotoPickerField(
            title: "Crag Images",
            selectedImages: $selectedImages,
            uploadStatus: createdCragId != nil ? photoUploadStatus : nil
          )

          submitButton
        }
        .padding(.top)
      }
      .background(Color.newBackgroundGray)
      .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
      .scrollDismissesKeyboard(.interactively)
      .alert(message: $errorMessage)
    }
  }

  private var backButtonView: some View {
    Button(action: {
      dismiss()
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(Color.newPrimaryColor)
    }
  }

  private var headerView: some View {
    HStack {
      backButtonView
      Text(createdCragId == nil ? "Create Crag" : "Upload Photos")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
    }
    .padding(.horizontal)
  }

  private var submitButton: some View {
    Button(action: {
      Task {
        await submitCrag()
      }
    }) {
      HStack {
        Spacer()
        if isSubmitting || isUploadingPhotos {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text(createdCragId == nil ? "Create Crag" : "Upload Remaining Photos")
            .fontWeight(.bold)
        }
        Spacer()
      }
      .padding()
      .background(isButtonEnabled ? Color.newPrimaryColor : Color.gray.opacity(0.5))
      .foregroundColor(.white)
      .cornerRadius(10)
      .padding(.horizontal)
    }
    .padding(.top, 10)
    .disabled(!isButtonEnabled)
  }

  private var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private var isButtonEnabled: Bool {
    if createdCragId == nil {
      return !isSubmitting && isFormValid
    } else {
      // Enable upload button only if there are pending or failed uploads
      return !isUploadingPhotos
        && selectedImages.indices.contains { index in
          let status = photoUploadStatus[index]
          return status == nil || (status != nil && status != .success)
        }
    }
  }

  private func navigateToCragDetails() {
    navigationManager.pop()
    navigationManager.pushView(.cragDetails(id: createdCragId ?? ""))
  }

  private func submitCrag() async {
    // Form validation already handled by isFormValid and button disabled state
    isSubmitting = true
    defer { isSubmitting = false }

    let createCragCommand = CreateCragInput(
      name: name,
      description: description.isEmpty ? nil : description,
      photos: selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
    )

    let result = await createCragClient.call(
      createCragCommand,
      authViewModel.getAuthData(),
      { message in
        errorMessage = message
      }
    )

    if let cragId = result?.id {
      createdCragId = cragId
      navigateToCragDetails()
    }
  }
}

// MARK: - Photo Upload Status Enum
enum PhotoUploadStatus: Equatable {
  case pending
  case uploading
  case success
  case failure(String)

  static func == (lhs: PhotoUploadStatus, rhs: PhotoUploadStatus) -> Bool {
    switch (lhs, rhs) {
    case (.pending, .pending), (.uploading, .uploading), (.success, .success):
      return true
    case (.failure(let lhsError), .failure(let rhsError)):
      return lhsError == rhsError
    default:
      return false
    }
  }
}

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateCragView()
  }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
