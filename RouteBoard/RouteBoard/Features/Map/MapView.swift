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

  // Function to calculate the distance between two points in kilometers
  func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let R = 6371.0  // Earth's radius in kilometers
    let dLat = (lat2 - lat1) * .pi / 180
    let dLon = (lon2 - lon1) * .pi / 180
    let a =
      sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2)
      * sin(dLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c
  }

  // Function to calculate optimal zoom level based on sector spread
  func calculateOptimalZoom(
    centerLocation: Components.Schemas.PointDto,
    sectors: [Components.Schemas.GlobeSectorResponseDto]
  ) -> Double {
    if sectors.isEmpty { return cragZoomLevel }

    // Calculate the maximum distance from center to any sector
    var maxDistance = 0.0
    for sector in sectors {
      guard let sectorLocation = sector.location else { continue }
      let distance = calculateDistance(
        lat1: centerLocation.latitude,
        lon1: centerLocation.longitude,
        lat2: sectorLocation.latitude,
        lon2: sectorLocation.longitude
      )
      maxDistance = max(maxDistance, distance)
    }

    // If all sectors are very close to center, use default zoom
    if maxDistance < 0.1 { return cragZoomLevel }

    // Calculate zoom level based on maximum distance
    // Convert zoom levels to MapKit distance values (higher distance = zoomed out more)
    if maxDistance < 0.5 { return 1000 }  // Very close sectors
    if maxDistance < 1 { return 2000 }  // Close sectors
    if maxDistance < 2 { return 4000 }  // Medium distance
    if maxDistance < 5 { return 8000 }  // Default for moderate spread
    if maxDistance < 10 { return 16000 }  // Wider spread
    if maxDistance < 20 { return 32000 }  // Very wide spread
    return 64000  // Extremely wide spread
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

      if mapViewModel.selectedCrag?.id == crag.id, let location = crag.location {
        // Calculate optimal zoom based on sector spread
        let optimalDistance = calculateOptimalZoom(
          centerLocation: location, sectors: mapViewModel.sectors)

        withAnimation(.easeInOut(duration: 0.3)) {
          setMapPosition(location: location, distance: optimalDistance)
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
        CragDetailCard(crag: selectedCrag, onClose: clearSelection, mapViewModel: mapViewModel)
          .transition(.move(edge: .bottom))
          .animation(.spring(), value: selectedCrag.id)
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
