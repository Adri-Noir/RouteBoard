// Created with <3 on 04.03.2025.

import GeneratedClient
import SwiftUI

struct CragHeaderView<Content: View>: View {
  @Environment(\.dismiss) var dismiss

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  let crag: CragDetails?
  let content: Content

  @State private var headerVisibleRatio: CGFloat = 1

  init(
    crag: CragDetails?,
    @ViewBuilder content: () -> Content
  ) {
    self.crag = crag
    self.content = content()
  }

  var cragPhotos: [PhotoDto] {
    crag?.photos ?? []
  }

  var navigationBarExpanded: some View {
    HStack(spacing: 0) {
      Spacer()

      // Could add crag-specific info here if needed
      if let locationName = crag?.locationName {
        Text("\(locationName)")
          .foregroundColor(.white)
          .padding(.horizontal, 10)
          .padding(.vertical, 10)
          .background(Color.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
    }
    .padding(20)
  }

  var compactNavigationBar: some View {
    HStack {
      Button(action: {
        dismiss()
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(8)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }

      Spacer()

      Group {
        AsyncImage(url: URL(string: cragPhotos.first?.url ?? "")) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } placeholder: {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .scaledToFill()
            .foregroundColor(Color.gray)
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }

        Text(crag?.name ?? "Crag")
          .font(.headline)
          .foregroundColor(.white)
          .lineLimit(1)
      }
      .opacity(1 - headerVisibleRatio)

      Spacer()

      Button(action: {
        // Menu action
      }) {
        Image(systemName: "ellipsis")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(10)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }
    }
  }

  public var body: some View {
    DetailsTopView(
      photos: cragPhotos,
      header: navigationBarExpanded,
      headerVisibleRatio: $headerVisibleRatio,
      overlay: compactNavigationBar,
      headerHeight: 300
    ) {
      content
    }
  }
}
