// Created with <3 on 16.03.2025.

import Combine
import GeneratedClient
import MapKit
import SwiftUI

// MARK: - Map Content
public struct MapContent: View {
  @Binding var mapPosition: MapCameraPosition
  var mapScope: Namespace.ID
  var showClusters: Bool
  var zoomLevel: Double
  var sectorZoomLevel: Double
  var mapViewModel: MapViewModel
  var selectCrag: (Components.Schemas.GlobeResponseDto) -> Void
  var selectCluster: (ClusterItem) -> Void

  public var body: some View {
    Map(position: $mapPosition, interactionModes: .all, scope: mapScope) {
      if showClusters {
        // Cluster annotations
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
                  .overlay(
                    Circle()
                      .stroke(Color.white, lineWidth: 1.5)
                  )
                  .shadow(radius: 2)

                Text("\(cluster.count)")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(.white)
              }
            }
          }
        }
      } else {
        // Crag annotations
        ForEach(mapViewModel.crags, id: \.self) { crag in
          if let location = crag.location, let name = crag.name {
            let isSelected = mapViewModel.selectedCrag?.id == crag.id

            Annotation(
              name,
              coordinate: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
              ),
              anchor: .bottom
            ) {
              Button {
                selectCrag(crag)
              } label: {
                VStack(spacing: 0) {
                  Image(systemName: "mountain.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(isSelected ? Color.blue : Color.orange)
                    .clipShape(Circle())
                    .overlay(
                      Circle()
                        .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)

                  // Triangle pointer
                  Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color.blue : Color.orange)
                    .offset(y: -5)
                }
              }
              .buttonStyle(MapScaleButtonStyle())
            }
          }
        }

        // Sector annotations (display only, not selectable)
        if zoomLevel < sectorZoomLevel {
          ForEach(mapViewModel.sectors, id: \.self) { sector in
            if let location = sector.location, let name = sector.name {
              Annotation(
                name,
                coordinate: CLLocationCoordinate2D(
                  latitude: location.latitude,
                  longitude: location.longitude
                ),
                anchor: .bottom
              ) {
                VStack(spacing: 0) {
                  // Photo or placeholder
                  if let imageUrl = sector.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                      switch phase {
                      case .success(let image):
                        image
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 40, height: 40)
                          .clipShape(Circle())
                          .overlay(
                            Circle()
                              .stroke(Color.white, lineWidth: 1.5)
                          )
                          .shadow(radius: 1)
                      case .failure:
                        placeholderImage()
                      default:
                        ProgressView()
                          .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
                          .frame(width: 40, height: 40)
                      }
                    }
                  } else {
                    placeholderImage()
                  }

                  // Triangle pointer
                  Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color.green)
                    .offset(y: -5)
                }
              }
            }
          }
        }
      }
    }
    .mapStyle(.hybrid(elevation: .automatic, pointsOfInterest: .excludingAll, showsTraffic: false))
    .mapControlVisibility(.hidden)
    .ignoresSafeArea()
  }

  private func placeholderImage() -> some View {
    Image(systemName: "mountain.2.circle.fill")
      .font(.system(size: 20))
      .foregroundColor(.white)
      .padding(6)
      .frame(width: 40, height: 40)
      .background(Color.green)
      .clipShape(Circle())
      .overlay(
        Circle()
          .stroke(Color.white, lineWidth: 1.5)
      )
      .shadow(radius: 1)
  }
}

private struct MapScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}
