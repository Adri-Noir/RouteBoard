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
  let latitude: Double
  let longitude: Double
}

struct CragMapView: View {
  let crag: CragDetails?

  var title: some View {
    Text("Location")
      .font(.title2)
      .fontWeight(.bold)
      .foregroundColor(Color.newTextColor)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      title

      if let location = crag?.location {
        Map {
          Marker(
            crag?.name ?? "",
            coordinate: CLLocationCoordinate2D(
              latitude: location.latitude, longitude: location.longitude)
          )
          .tint(.orange)
        }
        .mapControlVisibility(.hidden)
        .frame(height: 200)
        .cornerRadius(10)
      } else {
        Text("Location not available")
          .foregroundColor(.gray)
      }
    }
  }
}
