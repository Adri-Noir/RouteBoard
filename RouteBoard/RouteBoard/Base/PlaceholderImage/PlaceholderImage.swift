// Created with <3 on 12.03.2025.

import SwiftUI

struct PlaceholderImage: View {
  var iconFont: Font = .title

  var body: some View {
    Rectangle()
      .fill(Color.gray.opacity(0.2))
      .overlay(
        Image(systemName: "photo")
          .font(iconFont)
          .foregroundColor(.gray)
      )
  }
}
