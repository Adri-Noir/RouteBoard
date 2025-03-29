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

    let maxDimension: CGFloat = 2500

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

  @ViewBuilder
  func viewFromTwoImages(image1: Image, image2: Image) -> some View {
    ZStack {
      image1
      image2
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  var canvas: some View {
    GeometryReader { geometry in
      VStack {
        PhotoDrawingCanvas(createRouteImageModel: createRouteImageModel)
          .gesture(
            DragGesture(minimumDistance: 1)
              .onChanged { value in
                createRouteImageModel.imageCreatingState = .isCurrentlyDrawing
                createRouteImageModel.addPointToCanvas(value.location)

                // Get dimensions from the actual photo UIImage
                let photoWidth: CGFloat
                let photoHeight: CGFloat

                if let photoUIImage = createRouteImageModel.photoUIImage {
                  photoWidth = photoUIImage.size.width
                  photoHeight = photoUIImage.size.height
                } else {
                  photoWidth = geometry.size.width
                  photoHeight = geometry.size.height
                }

                // Calculate ratios between view coordinates and actual image coordinates
                let xCordRatio = Int(photoWidth) / Int(geometry.size.width)
                let yCordRatio = Int(photoHeight) / Int(geometry.size.height)

                // Convert view coordinates to image coordinates
                let xCord = Int(value.location.x) * xCordRatio
                let yCord = Int(value.location.y) * yCordRatio
                createRouteImageModel.addPointToImage(CGPoint(x: xCord, y: yCord))
              }
              .onEnded { value in
                createRouteImageModel.createRouteImage()
                guard let photoImage = createRouteImageModel.photoImage,
                  let routeImage = createRouteImageModel.routeImage
                else {
                  return
                }
                createRouteImageModel.createRouteImageFromView(
                  fromView: viewFromTwoImages(image1: photoImage, image2: routeImage))
                createRouteImageModel.imageCreatingState = .isShowingPhoto
              }
          )
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }

  // Styled button view
  func styledButton(_ text: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(text)
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
  }

  var content: some View {
    Group {
      VStack {
        // Show either camera preview or taken photo
        if createRouteImageModel.isShowingPreview {
          CameraPreview(source: createRouteImageModel.getPreviewSource())
        } else {
          GeometryReader { geometry in
            if createRouteImageModel.isEditingPhoto {
              createRouteImageModel.photoImage?
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
            }

            if createRouteImageModel.isShowingTakenPhoto {
              createRouteImageModel.combinedUIImage?
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
          }
        }
      }

      if createRouteImageModel.isEditingPhoto {
        canvas
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

        // Controls overlay
        VStack {
          // Top controls
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

          // Bottom controls
          if createRouteImageModel.isShowingPreview {
            // Photo capture button
            HStack {
              Spacer()

              PhotoCaptureButton {
                Task {
                  await createRouteImageModel.takePhoto()
                }
              }
              .frame(width: 70, height: 70)

              Spacer()
            }
          } else {
            // Post-capture buttons
            if createRouteImageModel.isEditingPhoto
              && createRouteImageModel.imageCreatingState != .isCurrentlyDrawing
            {
              // When in drawing mode, just show Retake
              HStack {
                styledButton("Retake photo") {
                  createRouteImageModel.resetToPreview()
                }
                Spacer()
              }
            } else {
              // Photo view mode buttons
              HStack(spacing: 12) {
                styledButton("Retake photo") {
                  createRouteImageModel.resetToPreview()
                }

                Spacer()

                styledButton("Redraw route") {
                  createRouteImageModel.resetToEditing()
                }
              }
            }
          }
        }
        .padding()
      }
      .cornerRadius(20)

      // Finish button - outside ZStack
      if createRouteImageModel.isShowingTakenPhoto && !createRouteImageModel.isEditingPhoto {
        Button(action: {
          Task {
            await uploadRouteImages()
          }
        }) {
          Text(createRouteImageModel.isUploading ? "Uploading..." : "Finish")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
        }
        .background(createRouteImageModel.isUploading ? Color.gray : Color.newPrimaryColor)
        .disabled(createRouteImageModel.isUploading)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 5)
      }
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
  }
}

#Preview {
  CreateRouteImageView(routeId: "0195cf3b-2c3c-76cb-83d1-46b45b8e85df")
}
