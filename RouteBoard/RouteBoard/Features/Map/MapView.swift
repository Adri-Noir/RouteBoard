// Created with <3 on 15.03.2025.

import Combine
import GeneratedClient
import MapKit
import SwiftUI

struct MapView: View {
  @Namespace var mapScope

  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  @StateObject private var mapViewModel = MapViewModel()

  @State private var mapPosition: MapCameraPosition = .automatic

  private var defaultZoomLevel: Double = 1_000_000_00
  private var cragZoomLevel: Double = 5000
  private var clusterZoomLevel: Double = 990_000
  private var sectorZoomLevel: Double = 20_000

  @State private var positionPublisher = PassthroughSubject<MKMapRect, Never>()
  @State private var cancellables = Set<AnyCancellable>()

  @State private var isLoading = false
  @State private var zoomLevel: Double = 0

  var showClusters: Bool {
    zoomLevel > mapViewModel.clusteringThreshold
  }

  func selectCrag(_ crag: Components.Schemas.GlobeResponseDto) {
    Task {
      isLoading = true
      defer { isLoading = false }
      await mapViewModel.selectCrag(crag)

      if mapViewModel.selectedCrag?.id == crag.id, let location = crag.location,
        zoomLevel > cragZoomLevel
      {
        withAnimation(.easeInOut(duration: 0.3)) {
          mapPosition = .camera(
            MapCamera(
              centerCoordinate: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
              ),
              distance: cragZoomLevel,
              heading: 0,
              pitch: 0
            )
          )
        }
      }
    }
  }

  func selectCluster(_ cluster: ClusterItem) {
    withAnimation(.easeInOut(duration: 0.3)) {
      mapPosition = .camera(
        MapCamera(
          centerCoordinate: cluster.coordinate,
          distance: clusterZoomLevel,
          heading: 0,
          pitch: 0
        )
      )
    }
  }

  func clearSelection() {
    mapViewModel.selectedCrag = nil
    mapViewModel.selectedSector = nil
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      Map(position: $mapPosition, interactionModes: .all, scope: mapScope) {
        if showClusters {
          ForEach(mapViewModel.clusters) { cluster in
            Annotation(
              "",
              coordinate: cluster.coordinate
            ) {
              Button {
                selectCluster(cluster)
              } label: {
                ZStack {
                  Circle()
                    .fill(Color.newPrimaryColor)
                    .frame(width: min(45, max(30, Double(cluster.count) * 2.5)))

                  Text("\(cluster.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                }
              }
            }
          }
        } else {
          ForEach(mapViewModel.crags, id: \.self) { crag in
            if let location = crag.location,
              let name = crag.name
            {
              let isSelected = mapViewModel.selectedCrag?.id == crag.id

              Annotation(
                name,
                coordinate: CLLocationCoordinate2D(
                  latitude: location.latitude,
                  longitude: location.longitude
                )
              ) {
                Button {
                  mapViewModel.selectedSector = nil
                  selectCrag(crag)
                } label: {
                  Image(systemName: "mountain.2.fill")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(isSelected ? Color.blue : Color.orange)
                    .clipShape(Circle())
                }
              }
            }
          }

          if zoomLevel < sectorZoomLevel {
            ForEach(mapViewModel.sectors, id: \.self) { sector in
              if let location = sector.location,
                let name = sector.name
              {
                let isSelected = mapViewModel.selectedSector?.id == sector.id

                Annotation(
                  name,
                  coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                  )
                ) {
                  Button {
                    mapViewModel.selectedCrag = nil
                    mapViewModel.selectSector(sector)
                  } label: {
                    Image(systemName: "mappin.circle.fill")
                      .foregroundColor(.white)
                      .padding(4)
                      .background(isSelected ? Color.blue : Color.green)
                      .clipShape(Circle())
                  }
                }
              }
            }
          }
        }
      }
      .mapStyle(.standard)
      .mapControls {
        MapCompass(scope: mapScope)
      }
      .mapScope(mapScope)
      .ignoresSafeArea()
      .onAppearOnce {
        mapPosition = .camera(
          MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 15, longitude: 0),
            distance: defaultZoomLevel,  // Large distance for zoomed out view
            heading: 0,
            pitch: 0
          )
        )

        // Set up the debounced position publisher
        positionPublisher
          .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
          .sink { [self] rect in
            let northEastPoint = MKMapPoint(x: rect.maxX, y: rect.minY)
            let southWestPoint = MKMapPoint(x: rect.minX, y: rect.maxY)

            let northEastCoord = northEastPoint.coordinate
            let southWestCoord = southWestPoint.coordinate

            let boundingBox = BoundingBox(
              northEast: northEastCoord,
              southWest: southWestCoord
            )

            Task {
              isLoading = true
              await mapViewModel.fetchCrags(boundingBox: boundingBox)
              isLoading = false
            }
          }
          .store(in: &cancellables)
      }
      .onMapCameraChange(frequency: .continuous) { context in
        positionPublisher.send(context.rect)
        zoomLevel = context.camera.distance
      }

      // Back button and loading indicator
      VStack {
        HStack {
          Button {
            dismiss()
          } label: {
            Image(systemName: "arrow.left")
              .font(.title2)
              .foregroundColor(.primary)
              .padding(12)
              .background(Color.black.opacity(0.8))
              .clipShape(Circle())
              .shadow(radius: 2)
          }

          Spacer()

          if isLoading {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(1.2)
              .padding(10)
              .background(Color.black.opacity(0.7))
              .clipShape(Circle())
              .shadow(radius: 2)
          }
        }
        .padding(.horizontal, 20)

        Spacer()
      }

      // Bottom detail cards
      if let selectedCrag = mapViewModel.selectedCrag {
        CragDetailCard(crag: selectedCrag, onClose: clearSelection)
          .transition(.move(edge: .bottom))
          .animation(.spring(), value: selectedCrag.id)
      } else if let selectedSector = mapViewModel.selectedSector {
        SectorDetailCard(sector: selectedSector, onClose: clearSelection)
          .transition(.move(edge: .bottom))
          .animation(.spring(), value: selectedSector.id)
      }
    }
    .navigationBarHidden(true)
    .task {
      mapViewModel.setAuthViewModel(authViewModel)
    }
  }
}

// Bottom detail card for crag
struct CragDetailCard: View {
  let crag: Components.Schemas.GlobeResponseDto
  let onClose: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header with close button
      HStack {
        Text(crag.name ?? "Unknown Crag")
          .font(.subheadline)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)
          .lineLimit(1)

        Spacer()

        Button(action: onClose) {
          Image(systemName: "xmark.circle.fill")
            .font(.body)
            .foregroundColor(.gray)
        }
        .buttonStyle(BorderlessButtonStyle())
      }

      HStack(spacing: 10) {
        // Crag image
        if let imageUrl = crag.imageUrl, let url = URL(string: imageUrl) {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.2))
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              Image(systemName: "photo")
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.gray.opacity(0.2))
            @unknown default:
              EmptyView()
            }
          }
          .frame(width: 60, height: 60)
          .cornerRadius(6)
          .clipped()
        } else {
          Image(systemName: "mountain.2.fill")
            .font(.system(size: 30))
            .foregroundColor(.orange)
            .frame(width: 60, height: 60)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(6)
        }

        // View details button
        if let cragId = crag.id {
          CragLink(cragId: cragId) {
            HStack {
              Text("View Details")
                .font(.caption)
                .fontWeight(.medium)

              Image(systemName: "arrow.right")
                .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
          }
          .buttonStyle(BorderlessButtonStyle())
        }
      }
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 3)
    .frame(maxWidth: 250)
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
  }
}

// Bottom detail card for sector
struct SectorDetailCard: View {
  let sector: Components.Schemas.GlobeSectorResponseDto
  let onClose: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header with close button
      HStack {
        Text(sector.name ?? "Unknown Sector")
          .font(.subheadline)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)
          .lineLimit(1)

        Spacer()

        Button(action: onClose) {
          Image(systemName: "xmark.circle.fill")
            .font(.body)
            .foregroundColor(.gray)
        }
        .buttonStyle(BorderlessButtonStyle())
      }

      HStack(spacing: 10) {
        // Sector image
        if let imageUrl = sector.imageUrl, let url = URL(string: imageUrl) {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.2))
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              Image(systemName: "photo")
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.gray.opacity(0.2))
            @unknown default:
              EmptyView()
            }
          }
          .frame(width: 60, height: 60)
          .cornerRadius(6)
          .clipped()
        } else {
          Image(systemName: "mappin.circle.fill")
            .font(.system(size: 30))
            .foregroundColor(.green)
            .frame(width: 60, height: 60)
            .background(Color.green.opacity(0.2))
            .cornerRadius(6)
        }

        // View details button
        if let sectorId = sector.id {
          SectorLink(sectorId: sectorId) {
            HStack {
              Text("View Details")
                .font(.caption)
                .fontWeight(.medium)

              Image(systemName: "arrow.right")
                .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(6)
          }
          .buttonStyle(BorderlessButtonStyle())
        }
      }
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 3)
    .frame(maxWidth: 250)
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
  }
}

#Preview {
  APIClientInjection {
    AuthInjectionMock {
      MapView()
    }
  }
}
