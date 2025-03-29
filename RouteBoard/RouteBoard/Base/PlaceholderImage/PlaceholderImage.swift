// Created with <3 on 12.03.2025.

import SwiftUI

struct PlaceholderImage: View {
  var iconFont: Font = .title
  var backgroundColor: Color = .gray.opacity(0.2)
  var iconColor: Color = .gray

  var body: some View {
    Rectangle()
      .fill(backgroundColor)
      .overlay(
        Image(systemName: "photo")
          .font(iconFont)
          .foregroundColor(iconColor)
      )
  }
}
