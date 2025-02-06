//
//  RouteLocationInfoView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.01.2025..
//

import GeneratedClient
import SwiftUI

struct RouteLocationInfoView: View {
  let route: RouteDetails?

  var body: some View {
    HStack(alignment: .center, spacing: 5) {
      SectorLink(sectorId: route?.sectorId ?? "") {
        HStack(alignment: .center, spacing: 10) {
          Image(systemName: "mountain.2")
            .font(.title2)
            .foregroundColor(Color.newTextColor)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

          MarqueeText(
            text: route?.sectorName ?? "",
            font: UIFont.preferredFont(forTextStyle: .title2),
            leftFade: 10,
            rightFade: 10,
            startDelay: 3
          )
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)
        }
      }

      HStack(alignment: .center, spacing: 10) {
        Image(systemName: "location")
          .font(.title2)
          .foregroundColor(Color.newTextColor)
          .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

        MarqueeText(
          text: "Kalnik",
          font: UIFont.preferredFont(forTextStyle: .title2),
          leftFade: 10,
          rightFade: 10,
          startDelay: 3
        )
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 20)
    .background(Color.newBackgroundGray)
    .clipShape(
      .rect(
        topLeadingRadius: 20, bottomLeadingRadius: 20, bottomTrailingRadius: 20,
        topTrailingRadius: 20)
    )
    .padding(.horizontal, 20)
  }

}
