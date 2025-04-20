// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteNavigationBar: View {
  let route: RouteDetails?
  let onAscentsView: () -> Void
  let onRouteARView: () -> Void

  @EnvironmentObject var navigationManager: NavigationManager
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var isDeletingRoute: Bool = false
  @State private var showDeleteConfirmation: Bool = false
  @State private var deleteError: String? = nil

  private let deleteRouteClient = DeleteRouteClient()

  var body: some View {
    HStack {
      // Back button
      Button(action: navigationManager.pop) {
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

        if authViewModel.isCreator, let route = route {
          Button(action: {
            navigationManager.pushView(.editRoute(routeDetails: route))
          }) {
            Label("Edit Route", systemImage: "pencil")
          }
        }

        if let route = route {
          if route.routePhotos?.isEmpty == false {
            Button(action: onRouteARView) {
              Label("Route AR", systemImage: "arkit")
            }
          }
          if authViewModel.isCreator {
            Divider()
            Button(
              role: .destructive,
              action: {
                showDeleteConfirmation = true
              }
            ) {
              Label("Delete Route", systemImage: "trash")
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
    .alert(
      isPresented: Binding<Bool>(
        get: { showDeleteConfirmation || deleteError != nil },
        set: { newValue in
          if !newValue {
            showDeleteConfirmation = false
            deleteError = nil
          }
        })
    ) {
      if let error = deleteError {
        return Alert(
          title: Text("Delete Failed"),
          message: Text(error),
          dismissButton: .default(Text("OK")) {
            deleteError = nil
          }
        )
      } else {
        return Alert(
          title: Text("Delete Route"),
          message: Text(
            "Are you sure you want to delete this route? This action cannot be undone."),
          primaryButton: .destructive(Text("Delete")) {
            Task {
              await deleteRoute()
            }
          },
          secondaryButton: .cancel {
            showDeleteConfirmation = false
          }
        )
      }
    }
  }

  private func deleteRoute() async {
    guard let routeId = route?.id else { return }
    isDeletingRoute = true
    let success = await deleteRouteClient.call(
      DeleteRouteInput(id: routeId),
      authViewModel.getAuthData()
    ) { errorMsg in
      DispatchQueue.main.async {
        deleteError = errorMsg
      }
    }
    isDeletingRoute = false
    if success {
      navigationManager.pop()
    } else if deleteError == nil {
      deleteError = "Failed to delete route. Please try again."
    }
  }
}
