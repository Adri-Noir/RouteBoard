// Created with <3 on 04.03.2025.

import GeneratedClient
import SwiftData
import SwiftUI

struct CragHeaderView<Content: View>: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var navigationManager: NavigationManager
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.modelContext) private var modelContext
  @Environment(\.isOfflineMode) private var isOfflineMode

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  let crag: CragDetails?
  let content: Content

  @State private var headerVisibleRatio: CGFloat = 1
  @State private var isLocationDetailsPresented: Bool = false
  @State private var isMenuOpen: Bool = false
  @State private var isCompactMenuPresented: Bool = false
  @State private var isDeletingCrag: Bool = false
  @State private var isDownloadingCrag: Bool = false
  @State private var isDownloadingError: Bool = false
  @State private var isAlreadyDownloadedCrag: Bool = false
  @State private var showDeleteConfirmation: Bool = false
  @State private var deleteError: String? = nil

  private let deleteCragClient = DeleteCragClient()
  private let downloadCragClient = DownloadCragClient()

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
      if let locationName = crag?.locationName, !isOfflineMode {
        Button {
          isLocationDetailsPresented.toggle()
        } label: {
          HStack(spacing: 4) {
            Text("\(locationName)")
              .foregroundColor(.white)

            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(.white)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 10)
          .background(Color.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .popover(
          isPresented: $isLocationDetailsPresented,
          attachmentAnchor: .point(.bottom),
          arrowEdge: .top
        ) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Location Details")
              .font(.headline)
              .padding(.bottom, 5)

            Text(locationName)
              .font(.subheadline)

            Divider()

            Button(action: {
              // Open in Maps action would go here
            }) {
              HStack {
                Image(systemName: "map")
                  .foregroundColor(Color.newPrimaryColor)
                Text("Open in Maps")
                  .foregroundColor(Color.newTextColor)
                Spacer()
              }
              .padding(.vertical, 6)
            }

            Button(action: {
              // Parking location action would go here
            }) {
              HStack {
                Image(systemName: "car")
                  .foregroundColor(Color.newPrimaryColor)
                Text("Parking Location")
                  .foregroundColor(Color.newTextColor)
                Spacer()
              }
              .padding(.vertical, 6)
            }

            Button(action: {
              // Parking location action would go here
            }) {
              HStack {
                Image(systemName: "info.circle")
                  .foregroundColor(Color.newPrimaryColor)
                Text("Approach Info")
                  .foregroundColor(Color.newTextColor)
                Spacer()
              }
              .padding(.vertical, 6)
            }
          }
          .padding()
          .frame(width: 240)
          .presentationCompactAdaptation(.popover)
          .preferredColorScheme(.light)
        }
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
          PlaceholderImage(iconFont: Font.body)
            .background(Color.white)
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }

        Text(crag?.name ?? "Crag")
          .font(.headline)
          .foregroundColor(.white)
          .lineLimit(1)
      }
      .opacity(1 - headerVisibleRatio)

      Spacer()

      if let crag = crag, !isOfflineMode {
        Button {
          isCompactMenuPresented.toggle()
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(.white)
            .font(.system(size: 24))
            .padding(12)
            .background(Color.black.opacity(0.75))
            .clipShape(Circle())
        }
        .popover(
          isPresented: $isCompactMenuPresented,
          attachmentAnchor: .point(.bottomTrailing),
          arrowEdge: .top
        ) {
          VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
              Button(action: {
                isCompactMenuPresented = false
                Task { await downloadCrag() }
              }) {
                Label(
                  isAlreadyDownloadedCrag
                    ? "Crag downloaded"
                    : (isDownloadingCrag ? "Downloading..." : "Download Crag"),
                  systemImage: "arrow.down.to.line"
                )
                .padding(.horizontal, 12)
                .foregroundColor(Color.newTextColor)
              }
              .disabled(isAlreadyDownloadedCrag || isDownloadingCrag)

              if crag.canModify ?? false {
                Button(action: {
                  isCompactMenuPresented = false
                  navigationManager.pushView(.createSector(cragId: crag.id ?? ""))
                }) {
                  Label("Create Sector", systemImage: "plus")
                    .padding(.horizontal, 12)
                    .foregroundColor(Color.newTextColor)
                }

                Button(action: {
                  isCompactMenuPresented = false
                  navigationManager.pushView(.editCrag(cragDetails: crag))
                }) {
                  Label("Edit Crag", systemImage: "pencil")
                    .padding(.horizontal, 12)
                    .foregroundColor(Color.newTextColor)
                }
              }
            }

            if crag.canModify ?? false {
              Divider()

              Button(action: {
                isCompactMenuPresented = false
                showDeleteConfirmation = true
              }) {
                Label("Delete Crag", systemImage: "trash")
                  .padding(.horizontal, 12)
                  .foregroundColor(Color.red)
              }
            }
          }
          .padding(.vertical, 12)
          .frame(width: 200)
          .preferredColorScheme(.light)
          .presentationCompactAdaptation(.popover)
        }
      }
    }
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
          title: Text("Delete Crag"),
          message: Text("Are you sure you want to delete this crag? This action cannot be undone."),
          primaryButton: .destructive(Text("Delete")) {
            Task {
              await deleteCrag()
            }
          },
          secondaryButton: .cancel {
            showDeleteConfirmation = false
          }
        )
      }
    }
    .alert(
      "Download Failed",
      isPresented: $isDownloadingError,
      actions: { Button("OK", role: .cancel) {} },
      message: { Text("Failed to download crag. Please try again.") }
    )
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

  private func deleteCrag() async {
    guard let cragId = crag?.id else { return }
    isDeletingCrag = true
    let success = await deleteCragClient.call(
      DeleteCragInput(id: cragId),
      authViewModel.getAuthData()
    ) { errorMsg in
      DispatchQueue.main.async {
        deleteError = errorMsg
      }
    }
    isDeletingCrag = false
    if success {
      navigationManager.pop()
    } else if deleteError == nil {
      deleteError = "Failed to delete crag. Please try again."
    }
  }

  private func downloadCrag() async {
    guard let cragId = crag?.id else { return }
    isDownloadingCrag = true
    defer { isDownloadingCrag = false }
    let response = await downloadCragClient.call(
      DownloadCragInput(id: cragId),
      authViewModel.getAuthData()
    ) { errorMsg in
      isDownloadingError = true
    }
    guard let cragResp = response else {
      isDownloadingError = true
      return
    }
    // Map crag photos
    var cragPhotosModel: [DownloadedPhoto] = []
    for photo in cragResp.photos ?? [] {
      if let urlString = photo.url,
        let localUrl = await PhotoDownloader.downloadPhotoToFile(url: urlString)
      {
        cragPhotosModel.append(DownloadedPhoto(id: photo.id, url: localUrl.absoluteString))
      }
    }
    // Map sectors
    var sectorsModel: [DownloadedSector] = []
    for sector in cragResp.sectors ?? [] {
      // Sector photos
      var sectorPhotosModel: [DownloadedPhoto] = []
      for sp in sector.photos ?? [] {
        if let urlString = sp.url,
          let localUrl = await PhotoDownloader.downloadPhotoToFile(url: urlString)
        {
          sectorPhotosModel.append(DownloadedPhoto(id: sp.id, url: localUrl.absoluteString))
        }
      }
      // Sector routes
      var sectorRoutesModel: [DownloadedRoute] = []
      for r in sector.routes ?? [] {
        // Download route photos
        var routePhotos: [DownloadedRoutePhoto] = []
        for photo in r.routePhotos ?? [] {
          if let imageUrlString = photo.image.url,
            let pathLineUrlString = photo.pathLine.url,
            let combinedImageUrlString = photo.combinedPhoto.url,
            let imageUrl = await PhotoDownloader.downloadPhotoToFile(url: imageUrlString),
            let pathLineUrl = await PhotoDownloader.downloadPhotoToFile(url: pathLineUrlString),
            let combinedImageUrl = await PhotoDownloader.downloadPhotoToFile(
              url: combinedImageUrlString)
          {
            let imagePhoto = DownloadedPhoto(id: photo.image.id, url: imageUrl.absoluteString)
            let pathLinePhoto = DownloadedPhoto(
              id: photo.pathLine.id, url: pathLineUrl.absoluteString)
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

        let localRoute = DownloadedRoute(
          id: r.id,
          name: r.name,
          descriptionText: r.description,
          grade: r.grade,
          createdAt: DateTimeConverter.convertDateStringToDate(dateString: r.createdAt ?? ""),
          routeType: r.routeType,
          length: r.length.map(Int.init),
          sectorId: sector.id,
          sectorName: sector.name,
          cragId: cragResp.id,
          cragName: cragResp.name,
          routeCategories: r.routeCategories,
          photos: routePhotos
        )
        sectorRoutesModel.append(localRoute)
      }
      let localSector = DownloadedSector(
        id: sector.id,
        name: sector.name,
        descriptionText: sector.description,
        location: sector.location,
        photos: sectorPhotosModel,
        routes: sectorRoutesModel,
        cragId: cragResp.id,
        cragName: cragResp.name
      )
      sectorsModel.append(localSector)
    }
    let localCrag = DownloadedCrag(
      id: cragResp.id,
      name: cragResp.name,
      descriptionText: cragResp.description,
      locationName: cragResp.locationName,
      sectors: sectorsModel,
      photos: cragPhotosModel
    )
    modelContext.insert(localCrag)
    do {
      try modelContext.save()
    } catch {
      print("Failed to save downloaded crag: \(error)")
    }
    isAlreadyDownloadedCrag = true
  }
}

#Preview {
  Navigator { _ in
    AuthInjectionMock {
      CragHeaderView(
        crag: CragDetails(id: "1", name: "Crag", locationName: "Location", photos: [])
      ) {
        Text("Content")
      }
    }
  }
}
