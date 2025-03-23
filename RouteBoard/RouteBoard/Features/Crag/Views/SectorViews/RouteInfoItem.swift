// Created with <3 on 22.03.2025.

import SwiftUI

struct RouteInfoItemLight: View {
  let icon: String
  let label: String

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.subheadline)
        .foregroundColor(.white)

      Text(label)
        .font(.subheadline)
        .foregroundColor(.white)
    }
  }
}

struct RouteInfoItem: View {
  let icon: String
  let label: String

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.footnote)
        .foregroundColor(Color.newTextColor)

      Text(label)
        .font(.footnote)
        .foregroundColor(Color.newTextColor)
    }
  }
}


