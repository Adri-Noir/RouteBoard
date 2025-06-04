// Created with <3 on 16.03.2025.

import SwiftUI

struct UserStatsView: View {
  let cragsVisited: Int
  let totalAscents: Int
  let totalPhotos: Int

  var body: some View {
    HStack(spacing: 30) {
      StatItem(value: "\(cragsVisited)", label: "Crags")
      Divider().frame(height: 40)
      StatItem(value: "\(totalAscents)", label: "Ascents")
      Divider().frame(height: 40)
      StatItem(value: "\(totalPhotos)", label: "Photos")
    }
    .padding(.vertical)
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .background(Color.white)
    .cornerRadius(12)
  }
}

struct UserStats {
  let cragsVisited: Int
  let followers: Int
  let following: Int
}
