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
  @State private var removedPhotoIds: Set<String> = []
  @State private var locationName: String = ""
  @State private var headerVisibleRatio: CGFloat = 1

  // Track the crag ID and photo upload status
  @State private var createdCragId: String? = nil

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var navigationManager: NavigationManager

  private let editCragClient = EditCragClient()
  private let createCragClient = CreateCragClient()
  private var cragDetails: CreateCragOutput? = nil

  // Add original values for edit mode
  private var originalName: String { cragDetails?.name ?? "" }
  private var originalDescription: String { cragDetails?.description ?? "" }
  private var originalLocationName: String { cragDetails?.locationName ?? "" }
  private var originalPhotos: [PhotoDto] { cragDetails?.photos ?? [] }

  // Add hasChanges computed property
  private var hasChanges: Bool {
    guard cragDetails != nil else { return true }  // Always true in create mode
    if name != originalName { return true }
    if description != originalDescription { return true }
    if locationName != originalLocationName { return true }
    if !selectedImages.isEmpty { return true }
    if !removedPhotoIds.isEmpty { return true }
    return false
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  init(cragDetails: CreateCragOutput) {
    self.cragDetails = cragDetails
  }

  init() {}

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollViewWithStickyHeader(
        header: {
          headerView
            .padding(.bottom, 12)
            .background(Color.newBackgroundGray)
        },
        headerOverlay: {
          ZStack {
            HStack {
              backButtonView
              Spacer()
            }
            Text(cragDetails == nil ? "Create Crag" : "Edit Crag")
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
        headerHeight: safeAreaInsets.top,
        onScroll: { _, headerVisibleRatio in
          self.headerVisibleRatio = headerVisibleRatio
        }
      ) {
        VStack(alignment: .leading, spacing: 20) {
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

          InputField(
            title: "Location Name",
            text: $locationName,
            placeholder: "Enter location name here... (optional)"
          )

          PhotoPickerField(
            title: "Crag Images",
            selectedImages: $selectedImages,
            existingPhotos: cragDetails?.photos ?? [],
            removedPhotoIds: $removedPhotoIds
          )

          submitButton
        }
        .padding(.bottom, safeAreaInsets.bottom)
      }
      .scrollDismissesKeyboard(.interactively)
      .alert(message: $errorMessage)
    }
    .task {
      if let cragDetails = cragDetails {
        name = cragDetails.name ?? ""
        description = cragDetails.description ?? ""
        locationName = cragDetails.locationName ?? ""
      }
    }
    .navigationBarHidden(true)
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
        Text(cragDetails == nil ? "Create Crag" : "Edit Crag")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Color.newPrimaryColor)

        Spacer()
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  private var submitButton: some View {
    Button(action: {
      Task {
        await submitCrag()
      }
    }) {
      HStack {
        Spacer()
        if isSubmitting {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text(cragDetails == nil ? "Create Crag" : "Edit Crag")
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
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  // Update isButtonEnabled to require hasChanges in edit mode
  private var isButtonEnabled: Bool {
    !isSubmitting && isFormValid && hasChanges
  }

  private func navigateToCragDetails() {
    navigationManager.pop()
    navigationManager.pushView(.cragDetails(id: createdCragId ?? ""))
  }

  private func submitCrag() async {
    // Form validation already handled by isFormValid and button disabled state
    isSubmitting = true
    defer { isSubmitting = false }

    if let cragDetails = cragDetails, let cragId = cragDetails.id {
      // Edit mode
      let editInput = EditCragInput(
        id: cragId,
        name: name == cragDetails.name ? nil : name,
        description: description == cragDetails.description ? nil : description,
        photos: selectedImages.isEmpty
          ? nil : selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) },
        locationName: locationName == cragDetails.locationName ? nil : locationName,
        photosToRemove: removedPhotoIds.isEmpty ? nil : Array(removedPhotoIds)
      )
      let result = await editCragClient.call(
        editInput,
        authViewModel.getAuthData(),
        { message in
          errorMessage = message
        }
      )
      if let cragId = result?.id {
        createdCragId = cragId
        navigateToCragDetails()
      }
    } else {
      // Create mode
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
  Navigator { _ in
    AuthInjectionMock {
      CreateCragView()
    }
  }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
