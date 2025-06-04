// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteAscentButton: View {
  let route: RouteDetails
  let userHasAscended: Bool
  let userAscentDate: Date?

  @EnvironmentObject var navigationManager: NavigationManager

  var body: some View {
    HStack {
      Spacer()

      VStack(spacing: 8) {
        if userHasAscended {
          Text(
            "Ascended on: \(userAscentDate?.formatted(date: .long, time: .omitted) ?? "Unknown")"
          )
          .foregroundColor(.white)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(Color.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        Button(action: {
          navigationManager.pushView(.routeLogAscent(routeId: route.id, routeGrade: route.grade))
        }) {
          HStack(spacing: 8) {
            Image(systemName: "plus")
              .foregroundColor(.white)
              .font(.system(size: 18, weight: .semibold))

            Text("Log Ascent")
              .foregroundColor(.white)
              .font(.system(size: 16, weight: .semibold))
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 16)
          .background(Color.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
      }

      Spacer()
    }
  }
}
