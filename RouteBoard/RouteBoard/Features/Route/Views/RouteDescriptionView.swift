// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteDescriptionView: View {
  let route: RouteDetails?

  var body: some View {
    if let route = route, let description = route.description, !description.isEmpty {
      VStack(alignment: .leading, spacing: 4) {
        Text("Description:")
          .font(.headline)
          .foregroundColor(.white.opacity(0.9))

        Text(description)
          .font(.body)
          .foregroundColor(.white.opacity(0.9))
          .lineLimit(3)
      }
      .padding(.top, 4)
    }
  }
}
