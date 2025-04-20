// Created with <3 on 03.04.2025.

import GeneratedClient
import MapKit
import PhotosUI
import SwiftUI

struct CreateSectorView: View {
  let cragId: String

  @State private var name: String = ""
  @State private var description: String = ""
  @State private var isSubmitting: Bool = false
  @State private var errorMessage: String? = nil
  @State private var selectedImages: [UIImage] = []
  @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
  @State private var removedPhotoIds: Set<String> = []

  // Track the sector ID and photo upload status
  @State private var createdSectorId: String? = nil

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var navigationManager: NavigationManager

  private let editSectorClient = EditSectorClient()
  private let createSectorClient = CreateSectorClient()
  private var sectorDetails: CreateSectorOutput? = nil

  @State private var headerVisibleRatio: CGFloat = 1

  init(sectorDetails: CreateSectorOutput) {
    self.cragId = sectorDetails.cragId ?? ""
    self.sectorDetails = sectorDetails
  }

  init(cragId: String) {
    self.cragId = cragId
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
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
            Text(sectorDetails == nil ? "Create Sector" : "Edit Sector")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(Color.newTextColor)
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
            existingPhotos: (sectorDetails?.photos ?? []).filter { photo in
              !removedPhotoIds.contains(photo.id)
            },
            onRemovePhoto: { photo in
              removedPhotoIds.insert(photo.id)
            }
          )
          submitButton
        }
        .padding(.bottom, safeAreaInsets.bottom)
      }
      .scrollDismissesKeyboard(.interactively)
      .alert(message: $errorMessage)
      .task {
        if let sectorDetails = sectorDetails {
          name = sectorDetails.name ?? ""
          description = sectorDetails.description ?? ""
          if let latitude = sectorDetails.location?.latitude,
            let longitude = sectorDetails.location?.longitude
          {
            selectedCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
          }
        }
      }
    }
    .navigationBarHidden(true)
    .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
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
    VStack {
      Spacer()
      HStack {
        backButtonView
        Text(sectorDetails == nil ? "Create Sector" : "Edit Sector")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)
        Spacer()
      }
    }

    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  private var submitButton: some View {
    Button(action: {
      Task {
        await submitSector()
      }
    }) {
      HStack {
        Spacer()
        if isSubmitting {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text(sectorDetails == nil ? "Create Sector" : "Edit Sector")
            .fontWeight(.bold)
        }
        Spacer()
      }
      .padding()
      .background(isButtonEnabled ? Color.newPrimaryColor : Color.gray.opacity(0.5))
      .foregroundColor(.white)
      .cornerRadius(10)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .padding(.top, 10)
    .disabled(!isButtonEnabled)
  }

  private var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCoordinate != nil
  }

  private var isButtonEnabled: Bool {
    !isSubmitting && isFormValid
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

    if let sectorDetails = sectorDetails,
      let oldLocation = sectorDetails.location
    {
      let coordinatesChanged =
        oldLocation.latitude != coordinate.latitude || oldLocation.longitude != coordinate.longitude
      let editInput = EditSectorInput(
        id: sectorDetails.id,
        name: name == sectorDetails.name ? nil : name,
        description: description == sectorDetails.description ? nil : description,
        locationLatitude: coordinatesChanged ? coordinate.latitude : nil,
        locationLongitude: coordinatesChanged ? coordinate.longitude : nil,
        photos: selectedImages.isEmpty
          ? nil : selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) },
        photosToRemove: removedPhotoIds.isEmpty ? nil : Array(removedPhotoIds)
      )
      let result = await editSectorClient.call(
        editInput,
        authViewModel.getAuthData(),
        { message in
          errorMessage = message
        }
      )
      if let sectorId = result?.id {
        createdSectorId = sectorId
        navigateToSectorDetails()
      }
    } else {
      // Create mode
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
}

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateSectorView(cragId: "sample-crag-id")
  }
}
