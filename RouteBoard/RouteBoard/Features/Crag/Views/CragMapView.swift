//
//  CragMapView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import MapKit
import SwiftUI

private struct MapLocation: Identifiable {
  let id = UUID()
  let name: String
  let latitude: Double
  let longitude: Double
  let isCrag: Bool
  let sectorId: String?
  let photoUrl: String?
}

struct CragMapView: View {
  let crag: CragDetails?
  @Binding var selectedSectorId: String?

  @State private var mapPosition: MapCameraPosition = .automatic
  @State private var mapInitialized = false

  private var mapLocations: [MapLocation] {
    var locations: [MapLocation] = []

    // Add crag location
    if let location = crag?.location {
      locations.append(
        MapLocation(
          name: crag?.name ?? "Crag",
          latitude: location.latitude,
          longitude: location.longitude,
          isCrag: true,
          sectorId: nil,
          photoUrl: nil
        ))
    }

    // Add sector locations
    if let sectors = crag?.sectors {
      for sector in sectors {
        if let location = sector.location, let name = sector.name {
          // Get the first photo URL if available
          let photoUrl = sector.photos?.first?.url

          locations.append(
            MapLocation(
              name: name,
              latitude: location.latitude,
              longitude: location.longitude,
              isCrag: false,
              sectorId: sector.id,
              photoUrl: photoUrl
            ))
        }
      }
    }

    return locations
  }

  private var mapRegion: MKCoordinateRegion? {
    guard let locations = mapLocations.first else { return nil }

    // Calculate the center point and span to include all locations
    if mapLocations.count > 1 {
      let latitudes = mapLocations.map { $0.latitude }
      let longitudes = mapLocations.map { $0.longitude }

      let minLat = latitudes.min() ?? locations.latitude
      let maxLat = latitudes.max() ?? locations.latitude
      let minLong = longitudes.min() ?? locations.longitude
      let maxLong = longitudes.max() ?? locations.longitude

      let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLong + maxLong) / 2
      )

      // Add some padding to the span
      let latDelta = (maxLat - minLat) * 1.5
      let longDelta = (maxLong - minLong) * 1.5

      return MKCoordinateRegion(
        center: center,
        span: MKCoordinateSpan(
          latitudeDelta: max(0.01, latDelta),
          longitudeDelta: max(0.01, longDelta)
        )
      )
    } else {
      // If there's only one location, center on it with a default span
      return MKCoordinateRegion(
        center: CLLocationCoordinate2D(
          latitude: locations.latitude,
          longitude: locations.longitude
        ),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
    }
  }

  private func recenterMap() {
    if let region = mapRegion {
      withAnimation {
        mapPosition = .region(region)
      }
    }
  }

  private func placeholderImage(isSelected: Bool) -> some View {
    Image(systemName: "photo")
      .font(.system(size: 20))
      .foregroundColor(.white)
      .padding(6)
      .frame(width: 40, height: 40)
      .background(isSelected ? Color.green : Color.blue)
      .clipShape(Circle())
      .overlay(
        Circle()
          .stroke(Color.white, lineWidth: isSelected ? 2 : 1.5)
      )
      .shadow(radius: isSelected ? 3 : 1)
      .scaleEffect(isSelected ? 1.1 : 1.0)
      .animation(.spring(response: 0.3), value: isSelected)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      if !mapLocations.isEmpty {
        ZStack(alignment: .bottomTrailing) {
          Map(position: $mapPosition) {
            ForEach(mapLocations) { location in
              if location.isCrag {
                // Custom marker for crag
                Annotation(
                  location.name,
                  coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude, longitude: location.longitude
                  ),
                  anchor: .bottom
                ) {
                  VStack(spacing: 0) {
                    Image(systemName: "mountain.2.fill")
                      .font(.system(size: 24))
                      .foregroundColor(.white)
                      .padding(8)
                      .background(Color.orange)
                      .clipShape(Circle())
                      .overlay(
                        Circle()
                          .stroke(Color.white, lineWidth: 2)
                      )
                      .shadow(radius: 2)

                    // Triangle pointer
                    Image(systemName: "arrowtriangle.down.fill")
                      .font(.system(size: 12))
                      .foregroundColor(.orange)
                      .offset(y: -5)
                  }
                }
              } else {
                // Marker for sector
                Annotation(
                  location.name,
                  coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude, longitude: location.longitude
                  ),
                  anchor: .bottom
                ) {
                  Button {
                    // Set the selectedSectorId directly from the location
                    if let sectorId = location.sectorId {
                      withAnimation {
                        selectedSectorId = sectorId
                      }
                    }
                  } label: {
                    VStack(spacing: 0) {
                      // Change color if this sector is selected
                      let isSelected = location.sectorId == selectedSectorId

                      // Photo or placeholder
                      if let photoUrl = location.photoUrl, let url = URL(string: photoUrl) {
                        // Photo is available
                        AsyncImage(url: url) { phase in
                          switch phase {
                          case .empty:
                            placeholderImage(isSelected: isSelected)
                          case .success(let image):
                            image
                              .resizable()
                              .aspectRatio(contentMode: .fill)
                              .frame(width: 40, height: 40)
                              .clipShape(Circle())
                              .overlay(
                                Circle()
                                  .stroke(Color.white, lineWidth: isSelected ? 2 : 1.5)
                              )
                              .shadow(radius: isSelected ? 3 : 1)
                              .scaleEffect(isSelected ? 1.1 : 1.0)
                              .animation(.spring(response: 0.3), value: isSelected)
                          case .failure:
                            placeholderImage(isSelected: isSelected)
                          @unknown default:
                            placeholderImage(isSelected: isSelected)
                          }
                        }
                      } else {
                        // No photo available
                        placeholderImage(isSelected: isSelected)
                      }

                      // Triangle pointer
                      Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? Color.green : Color.blue)
                        .offset(y: -5)
                    }
                  }
                  .buttonStyle(ScaleButtonStyle())
                }
              }
            }
          }
          .mapControlVisibility(.hidden)
          .onAppear {
            if !mapInitialized {
              if let region = mapRegion {
                mapPosition = .region(region)
              }
              mapInitialized = true
            }
          }

          // Re-center button
          Button(action: recenterMap) {
            Image(systemName: "dot.scope")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(.white)
              .padding(12)
              .background(Color.black.opacity(0.7))
              .clipShape(Circle())
              .shadow(radius: 2)
          }
          .padding(16)
        }
        .frame(height: 350)
        .cornerRadius(10)
      } else {
        Text("Location not available")
          .foregroundColor(.gray)
      }
    }
  }
}

// Custom button style that scales slightly when pressed
struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}
