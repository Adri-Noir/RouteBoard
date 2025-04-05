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
    .onChange(of: photoUploadStatus) { _, newStatus in
      // Automatically dismiss when all photos are uploaded successfully
      if createdCragId != nil && !selectedImages.isEmpty && allPhotosUploaded() {
        navigateToCragDetails()
      }
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
        if createdCragId == nil {
          await submitCrag()
        } else {
          uploadRemainingPhotos()
        }
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
      description: description.isEmpty ? nil : description
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

      if selectedImages.isEmpty {
        navigateToCragDetails()
        return
      }

      // Initialize photo upload statuses
      for index in selectedImages.indices {
        photoUploadStatus[index] = .pending
      }

      // Start uploading photos in parallel
      uploadRemainingPhotos()
    }
  }

  private func uploadRemainingPhotos() {
    if selectedImages.isEmpty {
      navigateToCragDetails()
      return
    }

    isUploadingPhotos = true
    activeUploads = 0

    // Upload only pending or failed photos in parallel
    for (index, _) in selectedImages.enumerated() {
      let status = photoUploadStatus[index]

      if status == nil || (status != nil && status != .success) {
        activeUploads += 1

        // Start a separate task for each photo
        Task {
          await uploadSinglePhoto(index: index)

          // Decrement active uploads counter using MainActor
          Task { @MainActor in
            activeUploads -= 1

            // If this was the last active upload, update the uploading state
            if activeUploads == 0 {
              isUploadingPhotos = false
            }
          }
        }
      }
    }

    // If no photos need to be uploaded, update state
    if activeUploads == 0 {
      isUploadingPhotos = false
    }
  }

  private func uploadSinglePhoto(index: Int) async {
    guard let cragId = createdCragId, index < selectedImages.count else { return }

    // Create a new client instance for each upload
    let uploadCragPhotoClient = UploadCragPhotosClient()

    // Mark as uploading
    Task { @MainActor in
      photoUploadStatus[index] = .uploading
    }

    // Convert image to JPEG data
    guard let imageData = selectedImages[index].jpegData(compressionQuality: 0.8) else {
      Task { @MainActor in
        photoUploadStatus[index] = .failure("Failed to process image")
      }
      return
    }

    // Create upload input
    let uploadInput = UploadCragPhotosInput(
      cragId: cragId,
      photo: imageData
    )

    // Upload the photo
    let success = await uploadCragPhotoClient.call(
      uploadInput,
      authViewModel.getAuthData(),
      { message in
        Task { @MainActor in
          photoUploadStatus[index] = .failure(message)
        }
      }
    )

    Task { @MainActor in
      if success {
        photoUploadStatus[index] = .success
      }
    }
  }

  private func allPhotosUploaded() -> Bool {
    return !selectedImages.isEmpty
      && selectedImages.indices.allSatisfy { index in
        photoUploadStatus[index] == .success
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
