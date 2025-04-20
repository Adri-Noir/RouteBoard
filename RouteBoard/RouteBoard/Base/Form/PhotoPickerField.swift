// Created with <3 on 02.04.2025.

import GeneratedClient  // Needed for PhotoDto
import PhotosUI
import SwiftUI
import UIKit

// Image item view component
private struct ImageItemView: View {
  let image: UIImage
  let index: Int
  let onRemove: (Int) -> Void

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 150, height: 150)
        .clipped()
        .cornerRadius(10)

      // X button for removing image
      Button(action: {
        onRemove(index)
      }) {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 22))
          .foregroundColor(.white)
          .background(Circle().fill(Color.black.opacity(0.7)))
      }
      .padding(5)
    }
  }
}

// Single photo item view for single-selection mode
private struct SingleImageItemView: View {
  let image: UIImage
  let onRemove: () -> Void

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipped()
        .cornerRadius(10)

      // X button for removing image
      Button(action: onRemove) {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 22))
          .foregroundColor(.white)
          .background(Circle().fill(Color.black.opacity(0.7)))
      }
      .padding(5)
    }
  }
}

// Add more button component
private struct AddMoreButton: View {
  let binding: Binding<[PhotosPickerItem]>

  var body: some View {
    PhotosPicker(selection: binding, matching: .images, preferredItemEncoding: .automatic) {
      VStack {
        Image(systemName: "plus")
          .font(.system(size: 30))
          .foregroundColor(Color.newPrimaryColor)
        Text("Add More")
          .font(.caption)
          .foregroundColor(Color.gray)
      }
      .frame(width: 100, height: 150)
      .background(Color.white)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.gray.opacity(0.3), lineWidth: 1)
      )
    }
  }
}

// Initial upload button component
private struct UploadButton: View {
  let binding: Binding<[PhotosPickerItem]>
  let isSingleMode: Bool

  var body: some View {
    PhotosPicker(
      selection: binding,
      maxSelectionCount: isSingleMode ? 1 : nil,
      matching: .images,
      preferredItemEncoding: .automatic
    ) {
      VStack(spacing: 10) {
        Image(systemName: "photo\(isSingleMode ? "" : ".stack").fill")
          .font(.system(size: 40))
          .foregroundColor(Color.newPrimaryColor)

        Text(isSingleMode ? "Upload photo" : "Upload images")
          .font(.subheadline)
          .foregroundColor(Color.gray)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 150)
      .background(Color.white)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.gray.opacity(0.3), lineWidth: 1)
      )
    }
  }
}

// Single mode upload button component
private struct SingleUploadButton: View {
  let binding: Binding<[PhotosPickerItem]>
  let image: UIImage?
  let onRemove: () -> Void

  var body: some View {
    if let image = image {
      SingleImageItemView(
        image: image,
        onRemove: onRemove
      )
    } else {
      PhotosPicker(
        selection: binding,
        maxSelectionCount: 1,
        matching: .images,
        preferredItemEncoding: .automatic
      ) {
        VStack(spacing: 10) {
          Image(systemName: "photo.fill")
            .font(.system(size: 40))
            .foregroundColor(Color.newPrimaryColor)

          Text("Upload photo")
            .font(.subheadline)
            .foregroundColor(Color.gray)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
      }
    }
  }
}

struct PhotoPickerField: View {
  let title: String
  @Binding var selectedImages: [UIImage]
  var singleMode: Bool = false
  var existingPhotos: [PhotoDto] = []
  var onRemovePhoto: ((PhotoDto) -> Void)? = nil

  @State private var photoItems: [PhotosPickerItem] = []

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      if singleMode {
        singleImageContent
      } else {
        multiImageContent
      }
    }
    .onChange(of: photoItems) { _, newItems in
      if singleMode && !newItems.isEmpty {
        // Replace image in single mode
        selectedImages = []
      }
      handlePhotoSelection(newItems)
    }
  }

  // Single image content view
  private var singleImageContent: some View {
    SingleUploadButton(
      binding: $photoItems,
      image: selectedImages.first,
      onRemove: {
        selectedImages = []
      }
    )
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  // Extract multi-image content to a computed property
  private var multiImageContent: some View {
    VStack(spacing: 15) {
      if !existingPhotos.isEmpty || !selectedImages.isEmpty {
        imagesGallery
      } else {
        UploadButton(binding: $photoItems, isSingleMode: false)
          .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
    }
  }

  // Extract gallery view to a computed property
  private var imagesGallery: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        // Existing photos from server
        ForEach(existingPhotos, id: \.id) { photo in
          ZStack(alignment: .topTrailing) {
            if let urlString = photo.url, let url = URL(string: urlString) {
              AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                  image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(10)
                case .failure(_):
                  PlaceholderImage()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                default:
                  ProgressView()
                    .frame(width: 150, height: 150)
                }
              }
            } else {
              Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 150)
                .cornerRadius(10)
            }
            // Remove button for existing photo
            if let onRemovePhoto = onRemovePhoto {
              Button(action: { onRemovePhoto(photo) }) {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 22))
                  .foregroundColor(.white)
                  .background(Circle().fill(Color.black.opacity(0.7)))
              }
              .padding(5)
            }
          }
          .scrollTransition { content, phase in
            content
              .opacity(phase.isIdentity ? 1 : 0)
              .scaleEffect(phase.isIdentity ? 1 : 0)
          }
          .id(photo.id)
        }
        // New images (not yet uploaded)
        ForEach(0..<selectedImages.count, id: \.self) { index in
          ImageItemView(
            image: selectedImages[index],
            index: index,
            onRemove: removeImage
          )
          .scrollTransition { content, phase in
            content
              .opacity(phase.isIdentity ? 1 : 0)
              .scaleEffect(phase.isIdentity ? 1 : 0)
          }
          .id("selected-\(index)")
        }
        AddMoreButton(binding: $photoItems)
          .scrollTransition { content, phase in
            content
              .opacity(phase.isIdentity ? 1 : 0)
              .scaleEffect(phase.isIdentity ? 1 : 0)
          }
          .id("add-more")
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .scrollTargetLayout()
    }
  }

  // Move photo selection handling to a method
  private func handlePhotoSelection(_ items: [PhotosPickerItem]) {
    Task {
      for item in items {
        if let data = try? await item.loadTransferable(type: Data.self),
          let uiImage = UIImage(data: data)
        {
          selectedImages.append(uiImage)
        }
      }
      // Clear selection to allow selecting the same images again if needed
      photoItems = []
    }
  }

  // Image removal function
  private func removeImage(at index: Int) {
    guard index < selectedImages.count else { return }
    selectedImages.remove(at: index)
  }
}

// Add a view modifier to get a single image
extension PhotoPickerField {
  func singlePhotoMode() -> PhotoPickerField {
    var field = self
    field.singleMode = true
    return field
  }
}

#Preview {
  VStack(spacing: 20) {
    PhotoPickerField(title: "Multiple Images", selectedImages: .constant([]))

    PhotoPickerField(title: "Single Image", selectedImages: .constant([]), singleMode: true)
  }
  .padding()
}
