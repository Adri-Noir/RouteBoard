// Created with <3 on 15.03.2025.

import GeneratedClient
import MapKit
import SwiftUI

public struct BoundingBox {
  let northEast: CLLocationCoordinate2D
  let southWest: CLLocationCoordinate2D
}

public struct ClusterItem: Identifiable, Hashable {
  public let id = UUID()
  let coordinate: CLLocationCoordinate2D
  let count: Int
  let crags: [Components.Schemas.GlobeResponseDto]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: ClusterItem, rhs: ClusterItem) -> Bool {
    lhs.id == rhs.id
  }
}

class MapViewModel: ObservableObject {
  @Published var clusters: [ClusterItem] = []

  @Published var crags: [Components.Schemas.GlobeResponseDto] = []
  @Published var sectors: [Components.Schemas.GlobeSectorResponseDto] = []
  @Published var selectedCrag: Components.Schemas.GlobeResponseDto?
  @Published var selectedSector: Components.Schemas.GlobeSectorResponseDto?

  private var sectorsCache: [String: [Components.Schemas.GlobeSectorResponseDto]] = [:]
  private var clustersCache: [ClusterItem] = []

  private var authViewModel: AuthViewModel?
  private let globeClient = GlobeClient()
  private let globeSectorClient = GlobeSectorClient()

  private var cragSet: Set<String> = []

  // Clustering parameters
  private let clusterDistance: Double = 200_000  // meters
  public let clusteringThreshold: Double = 1_000_000  // meters - zoom level at which to start clustering

  init() {}

  func setAuthViewModel(_ authViewModel: AuthViewModel) {
    self.authViewModel = authViewModel
  }

  func fetchCrags(boundingBox: BoundingBox) async {
    guard let authViewModel = authViewModel else {
      return
    }

    let command = GetGlobeCommand(
      northEast: Components.Schemas.PointDto(
        latitude: boundingBox.northEast.latitude,
        longitude: boundingBox.northEast.longitude
      ),
      southWest: Components.Schemas.PointDto(
        latitude: boundingBox.southWest.latitude,
        longitude: boundingBox.southWest.longitude
      )
    )

    let result = await globeClient.call(command, authViewModel.getAuthData())
    if let result = result {
      let newCrags = result.filter { crag in
        guard let id = crag.id else { return false }
        return !cragSet.contains(id)
      }

      if !newCrags.isEmpty {
        crags.append(contentsOf: newCrags)
        cragSet.formUnion(newCrags.compactMap(\.id))

        // Regenerate clusters when new crags are added
        generateClusters()
      }
    }
  }

  private func generateClusters() {
    var newClusters: [ClusterItem] = []

    let validCrags = crags.filter { $0.location != nil }

    if validCrags.isEmpty {
      clusters = []
      clustersCache = []
      return
    }

    var processedCrags = Set<String>()

    for crag in validCrags {
      guard let cragId = crag.id, let location = crag.location else { continue }

      if processedCrags.contains(cragId) {
        continue
      }

      let nearbyCrags = findNearbyCrags(
        coordinate: CLLocationCoordinate2D(
          latitude: location.latitude,
          longitude: location.longitude
        ),
        distance: clusterDistance,
        excludingProcessed: processedCrags
      )

      for nearbyCrag in nearbyCrags {
        if let id = nearbyCrag.id {
          processedCrags.insert(id)
        }
      }

      if nearbyCrags.count > 1 {
        let avgLat =
          nearbyCrags.compactMap { $0.location?.latitude }.reduce(0, +) / Double(nearbyCrags.count)
        let avgLng =
          nearbyCrags.compactMap { $0.location?.longitude }.reduce(0, +) / Double(nearbyCrags.count)

        let cluster = ClusterItem(
          coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLng),
          count: nearbyCrags.count,
          crags: nearbyCrags
        )

        newClusters.append(cluster)
      } else if let singleCrag = nearbyCrags.first, let location = singleCrag.location {
        let singleItem = ClusterItem(
          coordinate: CLLocationCoordinate2D(
            latitude: location.latitude, longitude: location.longitude),
          count: 1,
          crags: [singleCrag]
        )

        newClusters.append(singleItem)
      }
    }

    clustersCache = newClusters
    self.clusters = newClusters
  }

  private func findNearbyCrags(
    coordinate: CLLocationCoordinate2D,
    distance: Double,
    excludingProcessed processedIds: Set<String>
  ) -> [Components.Schemas.GlobeResponseDto] {
    var nearbyCrags: [Components.Schemas.GlobeResponseDto] = []

    for crag in crags {
      guard let cragId = crag.id, let location = crag.location else { continue }

      // Skip if already processed
      if processedIds.contains(cragId) {
        continue
      }

      let cragCoordinate = CLLocationCoordinate2D(
        latitude: location.latitude,
        longitude: location.longitude
      )

      // Calculate distance between points
      let cragLocation = CLLocation(
        latitude: cragCoordinate.latitude, longitude: cragCoordinate.longitude)
      let centerLocation = CLLocation(
        latitude: coordinate.latitude, longitude: coordinate.longitude)

      let distanceInMeters = cragLocation.distance(from: centerLocation)

      if distanceInMeters <= distance {
        nearbyCrags.append(crag)
      }
    }

    return nearbyCrags
  }

  func selectCrag(_ crag: Components.Schemas.GlobeResponseDto) async {
    if selectedCrag?.id == crag.id {
      selectedCrag = nil
      return
    }

    selectedCrag = crag

    guard let cragId = crag.id else {
      sectors = []
      return
    }

    if let cachedSectors = sectorsCache[cragId] {
      sectors = cachedSectors
      return
    }

    await fetchSectorsForCrag(cragId: cragId)
  }

  func selectSector(_ sector: Components.Schemas.GlobeSectorResponseDto) {
    if selectedSector?.id == sector.id {
      selectedSector = nil
      return
    }

    selectedSector = sector
  }

  func selectCluster(_ cluster: ClusterItem, zoomLevel: Double) {
    selectedCrag = nil
    sectors = []
  }

  func fetchSectorsForCrag(cragId: String) async {
    guard let authViewModel = authViewModel else {
      return
    }

    if let cachedSectors = sectorsCache[cragId] {
      sectors = cachedSectors
      return
    }

    let command = GetGlobeSectorCommand(cragId: cragId)

    let result = await globeSectorClient.call(command, authViewModel.getAuthData())
    if let result = result {
      sectorsCache[cragId] = result
      sectors = result
    }
  }
}
