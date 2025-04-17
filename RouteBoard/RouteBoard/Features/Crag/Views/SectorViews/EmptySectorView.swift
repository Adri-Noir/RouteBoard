// Created with <3 on 22.03.2025.

import SwiftUI

struct EmptySectorView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "mountain.2")
        .font(.system(size: 60))
        .foregroundColor(Color.newTextColor)

      Text("No sectors available")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      Text("This crag doesn't have any sectors yet.")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .frame(maxWidth: .infinity, minHeight: 200)
    .padding()
  }
}
