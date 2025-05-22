// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftData
import SwiftUI

struct RouteNavigationBar: View {
  let route: RouteDetails?
  let onAscentsView: () -> Void
  let onRouteARView: () -> Void

  @EnvironmentObject var navigationManager: NavigationManager
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.modelContext) private var modelContext

  @State private var isDeletingRoute: Bool = false
  @State private var showDeleteConfirmation: Bool = false
  @State private var deleteError: String? = nil
  @State private var isDownloadingRoute: Bool = false
  @State private var isDownloadingError: Bool = false

  @State private var isAlreadyDownloaded: Bool = false

  private let deleteRouteClient = DeleteRouteClient()
  private let downloadRouteClient = DownloadRouteClient()

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

        if let route = route {
          if route.routePhotos?.isEmpty == false {
            Button(action: onRouteARView) {
              Label("Route AR", systemImage: "arkit")
            }
          }
        }

        Button(action: {
          Task {
            await downloadRoute()
          }
        }) {
          Label(
            isAlreadyDownloaded
              ? "Route downloaded" : (isDownloadingRoute ? "Downloading..." : "Download Route"),
            systemImage: "arrow.down.to.line"
          )
        }
        .disabled(isAlreadyDownloaded || isDownloadingRoute)

        if let route = route, route.canModify ?? false {
          Divider()

          Button(action: {
            navigationManager.pushView(.editRoute(routeDetails: route))
          }) {
            Label("Edit Route", systemImage: "pencil")
          }

          Button(
            role: .destructive,
            action: {
              showDeleteConfirmation = true
            }
          ) {
            Label("Delete Route", systemImage: "trash")
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
    .padding(.top, 60)
    .task {
      isAlreadyDownloaded = isRouteAlreadyDownloaded()
    }
    .alert(
      "Download Failed",
      isPresented: $isDownloadingError,
      actions: { Button("OK", role: .cancel) {} },
      message: { Text("Failed to download route. Please try again.") }
    )

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
      deleteError = errorMsg
    }

    isDeletingRoute = false
    if success {
      navigationManager.pop()
    } else if deleteError == nil {
      deleteError = "Failed to delete route. Please try again."
    }
  }

  private func downloadRoute() async {
    isDownloadingRoute = true
    defer { isDownloadingRoute = false }

    let downloadedRoute = await downloadRouteClient.call(
      DownloadRouteInput(id: route?.id ?? ""),
      authViewModel.getAuthData()
    ) { errorMsg in
      isDownloadingError = true
    }

    guard let downloadedRoute = downloadedRoute else {
      isDownloadingError = true
      return
    }

    var routePhotos: [DownloadedRoutePhoto] = []
    for photo in downloadedRoute.routePhotos ?? [] {
      if let imageUrlString = photo.image.url,
        let pathLineUrlString = photo.pathLine.url,
        let combinedImageUrlString = photo.combinedPhoto.url,
        let imageUrl = await PhotoDownloader.downloadPhotoToFile(url: imageUrlString),
        let pathLineUrl = await PhotoDownloader.downloadPhotoToFile(url: pathLineUrlString),
        let combinedImageUrl = await PhotoDownloader.downloadPhotoToFile(
          url: combinedImageUrlString)
      {
        let imagePhoto = DownloadedPhoto(id: photo.image.id, url: imageUrl.absoluteString)
        let pathLinePhoto = DownloadedPhoto(id: photo.pathLine.id, url: pathLineUrl.absoluteString)
        let combinedImagePhoto = DownloadedPhoto(
          id: photo.combinedPhoto.id, url: combinedImageUrl.absoluteString)
        routePhotos.append(
          DownloadedRoutePhoto(
            id: photo.id,
            pathLinePhoto: pathLinePhoto,
            imagePhoto: imagePhoto,
            combinedImagePhoto: combinedImagePhoto
          )
        )
      }
    }

    let localRoute = DownloadedRoute.init(
      id: downloadedRoute.id,
      name: downloadedRoute.name,
      descriptionText: downloadedRoute.description,
      grade: downloadedRoute.grade,
      createdAt: DateTimeConverter.convertDateStringToDate(
        dateString: downloadedRoute.createdAt ?? ""),
      routeType: downloadedRoute.routeType,
      length: downloadedRoute.length.map(Int.init),
      sectorId: downloadedRoute.sectorId,
      sectorName: downloadedRoute.sectorName,
      cragId: downloadedRoute.cragId,
      cragName: downloadedRoute.cragName,
      routeCategories: downloadedRoute.routeCategories,
      photos: routePhotos
    )

    modelContext.insert(localRoute)
    // Persist the downloaded route and its photos immediately
    do {
      try modelContext.save()
    } catch {
      print("Failed to save downloaded route: \(error)")
    }
    isAlreadyDownloaded = true
  }

  private func isRouteAlreadyDownloaded() -> Bool {
    let downloadedRoute = try? modelContext.fetch(
      FetchDescriptor<DownloadedRoute>(
        predicate: #Predicate<DownloadedRoute> { $0.id == route?.id }
      )
    )
    return !(downloadedRoute?.isEmpty ?? true)
  }
}
