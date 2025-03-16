// Created with <3 on 15.03.2025.

import Combine
import GeneratedClient
import MapKit
import SwiftUI

struct MapView: View {
  @Namespace var mapScope

  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  private var defaultZoomLevel: Double = 1_000_000_00
  private var cragZoomLevel: Double = 5000
  private var clusterZoomLevel: Double = 990_000
  private var sectorZoomLevel: Double = 20_000

  @StateObject private var mapViewModel = MapViewModel()
  @State private var zoomLevel: Double = 0

  @State private var mapPosition: MapCameraPosition = .automatic

  @State private var positionPublisher = PassthroughSubject<MKMapRect, Never>()
  @State private var cancellables = Set<AnyCancellable>()

  @State private var isLoading = false

  var showClusters: Bool {
    zoomLevel > mapViewModel.clusteringThreshold
  }

  func setMapPosition(location: Components.Schemas.PointDto, distance: Double) {
    mapPosition = .camera(
      MapCamera(
        centerCoordinate: CLLocationCoordinate2D(
          latitude: location.latitude,
          longitude: location.longitude
        ),
        distance: distance,
        heading: 0,
        pitch: 0
      )
    )
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
          setMapPosition(location: location, distance: cragZoomLevel)
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
      MapContent(
        mapPosition: $mapPosition,
        mapScope: mapScope,
        showClusters: showClusters,
        zoomLevel: zoomLevel,
        sectorZoomLevel: sectorZoomLevel,
        mapViewModel: mapViewModel,
        selectCrag: selectCrag,
        selectCluster: selectCluster
      )
      .onAppearOnce {
        setMapPosition(
          location: Components.Schemas.PointDto(latitude: 15, longitude: 0),
          distance: defaultZoomLevel)

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
              defer { isLoading = false }
              await mapViewModel.fetchCrags(boundingBox: boundingBox)
            }
          }
          .store(in: &cancellables)
      }
      .onMapCameraChange(frequency: .continuous) { context in
        positionPublisher.send(context.rect)
        zoomLevel = context.camera.distance
        if !isLoading {
          isLoading = true
        }
      }

      MapControls(
        mapScope: mapScope,
        isLoading: isLoading,
        dismiss: dismiss
      )

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
    .mapScope(mapScope)
    .navigationBarHidden(true)
    .task {
      mapViewModel.setAuthViewModel(authViewModel)
    }
  }
}

#Preview {
  APIClientInjection {
    AuthInjectionMock {
      MapView()
    }
  }
}
