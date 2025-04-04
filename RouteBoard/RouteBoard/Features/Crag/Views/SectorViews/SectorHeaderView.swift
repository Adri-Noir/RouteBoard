// Created with <3 on 22.03.2025.

import SwiftUI

struct SectorHeaderView: View {
  let title: String
  let subtitle: String?
  let sectorPicker: any View

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        AnyView(sectorPicker)
        if let subtitle = subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(.subheadline)
            .foregroundColor(Color.newTextColor)
            .multilineTextAlignment(.leading)
        }
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
  }
}
