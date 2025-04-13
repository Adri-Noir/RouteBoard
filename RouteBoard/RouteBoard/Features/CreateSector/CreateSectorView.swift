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
  @EnvironmentObject var navigationManager: NavigationManager
  private let createSectorClient = CreateSectorClient()

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
        await submitSector()
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

  private func navigateToSectorDetails() {
    navigationManager.pop()
    navigationManager.pop()
    navigationManager.pushView(.sectorDetails(sectorId: createdSectorId ?? ""))
  }

  private func submitSector() async {
    isSubmitting = true
    defer { isSubmitting = false }

    guard let coordinate = selectedCoordinate else {
      errorMessage = "Please select a location on the map"
      return
    }

    let createSectorCommand = CreateSectorInput(
      name: name,
      description: description.isEmpty ? nil : description,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      cragId: cragId,
      photos: selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
    )

    let result = await createSectorClient.call(
      createSectorCommand,
      authViewModel.getAuthData(),
      { message in
        errorMessage = message
      }
    )

    if let sectorId = result?.id {
      createdSectorId = sectorId
      navigateToSectorDetails()
    }
  }
}

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateSectorView(cragId: "sample-crag-id")
  }
}
