// Created with <3 on 22.03.2025.

import SwiftUI

struct NoRoutesView: View {
  let selectedSectorId: String?

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "figure.climbing")
        .font(.system(size: 40))
        .foregroundColor(Color.newTextColor)

      Text("No routes available")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if selectedSectorId == nil {
        Text("There are no routes in any sector yet.")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor)
          .multilineTextAlignment(.center)
      } else {
        Text("This sector doesn't have any routes yet.")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
    .padding()
    .cornerRadius(12)
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }
}
