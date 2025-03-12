// Created with <3 on 12.03.2025.

import GeneratedClient
import SwiftUI

private struct ImageGalleryView: View {
  let images: [String]

  var body: some View {
    TabView {
      ForEach(images.indices, id: \.self) { index in
        AsyncImage(url: URL(string: images[index])) { image in
          image
            .resizable()
            .scaledToFit()
        } placeholder: {
          PlaceholderImage()
        }
      }
    }
    .tabViewStyle(PageTabViewStyle())
  }
}

private struct NoPicturesView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "photo.on.rectangle.angled")
        .font(.system(size: 50))
        .foregroundColor(.gray)

      Text("No pictures available")
        .font(.headline)
        .foregroundColor(.gray)

      Text("Pictures will appear here when added")
        .font(.subheadline)
        .foregroundColor(.gray.opacity(0.8))
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.newBackgroundGray.opacity(0.5))
    .cornerRadius(10)
  }
}

struct GalleryView: View {
  @State private var isModalPresented = false
  private var images: [String]

  init(images: [PhotoDto]?) {
    self.images = images?.compactMap { $0.url } ?? []
  }

  var title: some View {
    Text("Gallery")
      .font(.headline)
      .foregroundColor(Color.newTextColor)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      title

      if images.isEmpty {
        NoPicturesView()
      } else {
        LazyVGrid(
          columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 5
        ) {
          ForEach(0..<images.count, id: \.self) { index in
            Color.newBackgroundGray
              .aspectRatio(1, contentMode: .fill)
              .overlay(
                AsyncImage(url: URL(string: images[index])) { image in
                  image
                    .resizable()
                    .scaledToFill()
                } placeholder: {
                  PlaceholderImage()
                }
              ).clipped()
              .cornerRadius(10)
          }
        }
        .onTapGesture {
          isModalPresented = true
        }
        .sheet(isPresented: $isModalPresented) {
          ImageGalleryView(images: images)
        }
      }
    }
  }
}
