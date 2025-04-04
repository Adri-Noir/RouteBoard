// Created with <3 on 03.04.2025.

import GeneratedClient
import MapKit
import PhotosUI
import SwiftUI

struct CreateSectorView: View {
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var isSubmitting: Bool = false
  @State private var errorMessage: String? = nil
  @State private var selectedImages: [UIImage] = []
  @State private var selectedCoordinate: CLLocationCoordinate2D? = nil

  // Sector-specific properties
  let cragId: String

  // Track the sector ID and photo upload status
  @State private var createdSectorId: String? = nil
  @State private var photoUploadStatus: [Int: PhotoUploadStatus] = [:]
  @State private var isUploadingPhotos: Bool = false
  @State private var activeUploads: Int = 0

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let createSectorClient = CreateSectorClient()

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
          title: "Sector Name",
          text: $name,
          placeholder: "Enter sector name here..."
        )

        TextAreaField(
          title: "Description",
          text: $description,
          placeholder: "Enter sector description here... (optional)"
        )

        MapLocationPickerField(
          title: "Location",
          selectedCoordinate: $selectedCoordinate,
          errorMessage: $errorMessage
        )

        PhotoPickerField(
          title: "Sector Images",
          selectedImages: $selectedImages,
          uploadStatus: createdSectorId != nil ? photoUploadStatus : nil
        )

        submitButton
      }
      .padding(.top)
    }
    .navigationBarBackButtonHidden()
    .toolbar(.hidden, for: .navigationBar)
    .padding(.top, 2)
    .background(Color.newBackgroundGray)
    .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
    .scrollDismissesKeyboard(.interactively)
    .alert(message: $errorMessage)
    .onChange(of: photoUploadStatus) { _, newStatus in
      // Automatically dismiss when all photos are uploaded successfully
      if createdSectorId != nil && !selectedImages.isEmpty && allPhotosUploaded() {
        dismiss()
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
      Text(createdSectorId == nil ? "Create Sector" : "Upload Photos")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
    }
    .padding(.horizontal)
  }

  private var submitButton: some View {
    Button(action: {
      Task {
        if createdSectorId == nil {
          await submitSector()
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
          Text(createdSectorId == nil ? "Create Sector" : "Upload Remaining Photos")
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
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCoordinate != nil
  }

  private var isButtonEnabled: Bool {
    if createdSectorId == nil {
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

  private func submitSector() async {
    // Form validation already handled by isFormValid and button disabled state
    isSubmitting = true
    defer { isSubmitting = false }

    guard let coordinate = selectedCoordinate else {
      errorMessage = "Please select a location on the map"
      return
    }

    let createSectorCommand = CreateSectorCommand(
      name: name,
      description: description.isEmpty ? nil : description,
      location: Components.Schemas.PointDto(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      cragId: cragId
    )

    let result = await createSectorClient.call(
      createSectorCommand,
      authViewModel.getAuthData(),
      { message in
        errorMessage = message
      }
    )

    if selectedImages.isEmpty {
      dismiss()
      return
    }

    if let sectorId = result?.id {
      createdSectorId = sectorId

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
      dismiss()
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

              // Check if all photos are uploaded after all uploads complete
              if allPhotosUploaded() {
                dismiss()
              }
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
    guard let sectorId = createdSectorId, index < selectedImages.count else { return }

    // Create a new client instance for each upload
    let uploadSectorPhotoClient = UploadSectorPhotosClient()

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
    let uploadInput = UploadSectorPhotosInput(
      sectorId: sectorId,
      photo: imageData
    )

    // Upload the photo
    let success = await uploadSectorPhotoClient.call(
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

        // Check if this was the last photo to upload
        if allPhotosUploaded() {
          dismiss()
        }
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

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateSectorView(cragId: "sample-crag-id")
  }
}
