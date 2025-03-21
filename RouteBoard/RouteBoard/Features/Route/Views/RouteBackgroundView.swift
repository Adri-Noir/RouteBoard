// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteBackgroundView: View {
  let route: RouteDetails?
  let isFullscreenMode: Bool
  let onTap: () -> Void

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Route image
        if let route = route, let firstPhoto = route.routePhotos?.first?.image?.url,
          !firstPhoto.isEmpty
        {
          AsyncImage(url: URL(string: firstPhoto)) { phase in
            switch phase {
            case .empty:
              Color.gray
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
              Image("TestingSamples/limski/pikachu")
                .resizable()
                .aspectRatio(contentMode: .fill)
            @unknown default:
              Image("TestingSamples/limski/pikachu")
                .resizable()
                .aspectRatio(contentMode: .fill)
            }
          }
          .frame(width: geometry.size.width, height: geometry.size.height)
        } else {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

        // Gradient overlay
        LinearGradient(
          gradient: Gradient(colors: [
            Color.black.opacity(isFullscreenMode ? 0 : 1),
            Color.black.opacity(isFullscreenMode ? 0 : 0.75),
            Color.black.opacity(isFullscreenMode ? 0 : 0.5),
            Color.black.opacity(0),
          ]),
          startPoint: .bottom,
          endPoint: .top
        )
        .animation(.easeInOut(duration: 0.3), value: isFullscreenMode)
      }
      .onTapGesture {
        onTap()
      }
    }
  }
}
