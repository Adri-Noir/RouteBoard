//
//  SectorLocationInfoView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 24.01.2025..
//

import SwiftUI
import GeneratedClient

struct SectorLocationInfoView: View {
  var sector: SectorDetails?

  var body: some View {
    HStack(alignment: .center, spacing: 5) {
      CragLink(cragId: sector?.cragId ?? "") {
        HStack(alignment: .center, spacing: 10) {
          Image(systemName: "mountain.2")
            .font(.title2)
            .foregroundColor(Color.newTextColor)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

          MarqueeText(
            text: sector?.cragName ?? "Crag",
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
