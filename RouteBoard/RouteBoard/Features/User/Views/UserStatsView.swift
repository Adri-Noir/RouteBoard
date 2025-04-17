// Created with <3 on 16.03.2025.

import SwiftUI

struct UserStatsView: View {
  let cragsVisited: Int

  var body: some View {
    HStack(spacing: 30) {
      StatItem(value: "\(cragsVisited)", label: "Crags")
      Divider().frame(height: 40)
      StatItem(value: "0", label: "Followers")  // API doesn't provide followers count yet
      Divider().frame(height: 40)
      StatItem(value: "0", label: "Following")  // API doesn't provide following count yet
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
