// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteCharacteristicsView: View {
  let climbingTypes: [UserClimbingType]

  var body: some View {
    if !climbingTypes.isEmpty {
      VStack(alignment: .leading, spacing: 4) {
        Text("Climbing Characteristics:")
          .font(.headline)
          .foregroundColor(.white.opacity(0.9))
          .padding(.horizontal, ThemeExtension.horizontalPadding)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(
              Array(Set(climbingTypes)).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self
            ) { type in
              Text(type.rawValue)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.newPrimaryColor.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .padding(.vertical, 4)
        }
      }
      .padding(.top, 4)
    }
  }
}
