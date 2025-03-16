// Created with <3 on 16.03.2025.

import SwiftUI
import GeneratedClient

struct PhotosGridView: View {
  let photos: [Components.Schemas.PhotoDto]?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Photos")
          .font(.headline)
          .foregroundColor(Color.newTextColor)

        Spacer()

        Button(action: {}) {
          Text("See All")
            .font(.subheadline)
            .foregroundColor(Color.newPrimaryColor)
        }
      }

      if let photos = photos, !photos.isEmpty {
        LazyVGrid(
          columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8
        ) {
          ForEach(photos, id: \.id) { photo in
            if let photoUrl = photo.url, !photoUrl.isEmpty {
              AsyncImage(url: URL(string: photoUrl)) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Image(systemName: "photo")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .foregroundColor(Color.newTextColor)
              }
              .frame(height: 75)
              .frame(maxWidth: .infinity)
              .background(Color.gray.opacity(0.3))
              .cornerRadius(8)
            } else {
              Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 75)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.newTextColor)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
          }
        }
      } else {
        Text("No photos available")
          .foregroundColor(Color.newTextColor.opacity(0.7))
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}
