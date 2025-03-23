// Created with <3 on 22.03.2025.

import SwiftUI

struct SectorLoadingView: View {
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)
        .padding(.bottom, 8)

      Text("Loading sector data...")
        .font(.headline)
        .foregroundColor(Color.newTextColor)
    }
    .frame(maxWidth: .infinity, minHeight: 200)
    .padding()
  }
}
