// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteNavigationBar: View {
  let route: RouteDetails?
  let onDismiss: () -> Void
  let onAscentsView: () -> Void
  let onRouteARView: () -> Void

  @EnvironmentObject var navigationManager: NavigationManager

  var body: some View {
    HStack {
      // Back button
      Button(action: onDismiss) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(12)
          .background(Color.black.opacity(0.6))
          .clipShape(Circle())
      }

      Spacer()

      // Ascents count button
      Button(action: onAscentsView) {
        HStack(spacing: 6) {
          Image(systemName: "figure.climbing")
            .foregroundColor(.white)

          Text("\(route?.ascents?.count ?? 0)")
            .foregroundColor(.white)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
      }

      // Menu button
      Menu {
        Button(action: {
          navigationManager.pushView(.createRouteImage(routeId: route?.id ?? ""))
        }) {
          Label("Add Route Image", systemImage: "camera")
        }

        if let route = route {
          if route.routePhotos?.isEmpty == false {
            Button(action: onRouteARView) {
              Label("Route AR", systemImage: "arkit")
            }
          }
        }
      } label: {
        Image(systemName: "ellipsis")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(16)
          .background(Color.black.opacity(0.6))
          .clipShape(Circle())
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.top, 60)  // Account for safe area
  }
}
