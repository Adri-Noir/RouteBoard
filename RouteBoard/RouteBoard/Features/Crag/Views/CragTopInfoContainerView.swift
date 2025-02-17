//
//  CragTopInfoContainerView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

private struct CragWeatherInfoView: View {
  var icon: String
  var value: String
  var unit: String
  var title: String

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(Color.newTextColor)
          .font(.title3)

        HStack(alignment: .top, spacing: 2) {
          Text(value)
            .foregroundColor(Color.newTextColor)
            .font(.title2)
            .fontWeight(.semibold)
          Text(unit)
            .foregroundColor(Color.newTextColor.opacity(0.75))
            .font(.caption)
            .padding(.top, 5)

        }
      }
      Text(title)
        .foregroundColor(Color.newTextColor.opacity(0.75))
        .font(.caption)
        .fontWeight(.semibold)
    }
  }
}

struct CragTopInfoContainerView: View {
  var crag: CragDetails?

  var body: some View {
    VStack(spacing: 20) {
      HStack {
        CragWeatherInfoView(icon: "thermometer", value: "6", unit: "°C", title: "Temperature")

        Spacer()

        CragWeatherInfoView(icon: "drop.halffull", value: "40", unit: "%", title: "Humidity")

        Spacer()

        CragWeatherInfoView(icon: "wind", value: "5", unit: "km/h", title: "Wind Speed")
      }
      .padding(20)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 20))

      GradesGraphView(gradesModel: GradesGraphModel(crag: crag))
        .frame(height: 200)
    }
  }
}
