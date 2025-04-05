//
//  CreateRouteImageView.swift
//  RouteBoard
//
//  Created with <3 on 06.07.2024..
//

import GeneratedClient
import SwiftUI

struct CreateRouteImageView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  @StateObject private var createRouteImageModel = CreateRouteImageModel()

  // Route ID to be passed from parent view
  let routeId: String

  // State for alert
  @State private var errorMessage: String? = nil
  @State private var showSuccessMessage: Bool = false

  init(routeId: String) {
    self.routeId = routeId
  }

  // Extract the upload functionality into a separate function
  private func uploadRouteImages() async {
    // Get route ID and convert Image objects to UIImage for upload
    guard let routeId = createRouteImageModel.routeId,
      let photoUIImage = createRouteImageModel.photoUIImage,
      let routeUIImage = createRouteImageModel.routeUIImage
    else {
      // Handle missing data
      errorMessage = "Missing required image data for upload"
      return
    }

    // Create a UIImage from the SwiftUI Image for the combined image
    var combinedUIImage: UIImage?
    if let swiftUIImage = createRouteImageModel.combinedUIImage {
      let renderer = ImageRenderer(content: swiftUIImage)
      combinedUIImage = renderer.uiImage
    }

    guard let combinedUIImage = combinedUIImage else {
      errorMessage = "Failed to create combined image"
      return
    }

    let maxDimension: CGFloat = 1200

    let photoAspect = photoUIImage.size.width / photoUIImage.size.height

    let photoTargetSize: CGSize
    if photoAspect > 1 {
      photoTargetSize = CGSize(width: maxDimension, height: maxDimension / photoAspect)
    } else {
      photoTargetSize = CGSize(width: maxDimension * photoAspect, height: maxDimension)
    }

    let scaledPhotoUIImage = UIGraphicsImageRenderer(size: photoTargetSize).image { _ in
      photoUIImage.draw(in: CGRect(origin: .zero, size: photoTargetSize))
    }

    let scaledRouteUIImage = UIGraphicsImageRenderer(size: photoTargetSize).image { context in
      context.cgContext.setFillColor(UIColor.clear.cgColor)
      context.cgContext.fill(CGRect(origin: .zero, size: photoTargetSize))

      routeUIImage.draw(in: CGRect(origin: .zero, size: photoTargetSize))
    }

    let scaledCombinedUIImage = UIGraphicsImageRenderer(size: photoTargetSize).image { _ in
      combinedUIImage.draw(in: CGRect(origin: .zero, size: photoTargetSize))
    }

    // Convert images to data for upload
    guard let photoData = scaledPhotoUIImage.jpegData(compressionQuality: 0.9),
      let linePhotoData = scaledRouteUIImage.pngData(),
      let combinedPhotoData = scaledCombinedUIImage.jpegData(compressionQuality: 0.9)
    else {
      errorMessage = "Failed to convert images to data"
      return
    }

    createRouteImageModel.isUploading = true

    let uploadInput = UploadRouteImageInput(
      routeId: routeId,
      photo: photoData,
      linePhoto: linePhotoData,
      combinedPhoto: combinedPhotoData
    )

    let client = UploadRouteImageClient()
    let success = await client.call(uploadInput, authViewModel.getAuthData()) { message in
      errorMessage = "Upload error: \(message)"
    }

    if success {
      showSuccessMessage = true
      try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    createRouteImageModel.isUploading = false

    if success {
      dismiss()
    }
  }

  var content: some View {
    Group {
      if createRouteImageModel.isShowingPreview {
        // Camera preview phase
        PhotoTakingOverlayView(createRouteImageModel: createRouteImageModel)
      } else if createRouteImageModel.isEditingPhoto {
        // Drawing phase
        ZStack {
          // Background photo
          GeometryReader { geometry in
            createRouteImageModel.photoImage?
              .resizable()
              .scaledToFill()
              .frame(width: geometry.size.width, height: geometry.size.height)

            // Drawing canvas overlay - Moved inside GeometryReader
            CreateRouteOverlayView(
              createRouteImageModel: createRouteImageModel,
              viewSize: geometry.size  // Pass the size
            )
          }  // End GeometryReader

          // Editing phase controls - only show Retake button during drawing
          if createRouteImageModel.imageCreatingState != .isCurrentlyDrawing {
            VStack {
              Spacer()
              HStack {
                Button(action: {
                  createRouteImageModel.resetToPreview()
                }) {
                  Text("Retake photo")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .overlay(
                      RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(8)

                Spacer()
              }
              .padding(.horizontal)
            }
          }
        }
      } else {
        // Photo preview/confirmation phase
        ConfirmPhotoOverlayView(
          createRouteImageModel: createRouteImageModel,
          onRetake: { createRouteImageModel.resetToPreview() },
          onRedraw: { createRouteImageModel.resetToEditing() },
          onFinish: {
            Task {
              await uploadRouteImages()
            }
          }
        )
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Title at the top
      Text("Capture Route")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.black.opacity(0.7))

      // Main content area
      ZStack {
        content
          .cornerRadius(20)

        // Close button overlay
        VStack {
          HStack {
            Button(action: {
              dismiss()
            }) {
              Image(systemName: "xmark")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding(12)
            }

            Spacer()
          }

          Spacer()
        }
        .padding()
      }
      .cornerRadius(20)
    }
    .background(Color.black)
    .task {
      createRouteImageModel.setRouteId(routeId)
      createRouteImageModel.canvasPoints.removeAll()
    }
    .alert(
      message: $errorMessage
    )
    .alert(
      "Success",
      isPresented: $showSuccessMessage,
      actions: {
        Button("OK") {
          showSuccessMessage = false
          dismiss()
        }
      },
      message: {
        Text("Route images uploaded successfully")
      }
    )
    .navigationBarHidden(true)
  }
}

#Preview {
  AuthInjectionMock {
    CreateRouteImageView(routeId: "0195cf3b-2c3c-76cb-83d1-46b45b8e85df")
  }
}
