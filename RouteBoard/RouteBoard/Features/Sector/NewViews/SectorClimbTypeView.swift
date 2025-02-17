//
//  SectorClimbTypeView.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import SwiftUI

struct SectorClimbTypeView: View {
  let climbType = [
    "Crimps", "Jugs", "Vertical", "Slab", "Crack", "Endurance",
  ]
  let climbTypeIcons = [
    "bolt.fill", "hand.thumbsup.fill", "arrow.up.and.down", "arrow.up", "text.book.closed",
    "timer",
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Climb Types")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(0..<6) { index in
            VStack(spacing: 0) {
              Image(systemName: climbTypeIcons[index % climbTypeIcons.count])
                .font(.title)
                .foregroundColor(Color.newTextColor)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

              Text(climbType[index % climbType.count])
                .fontWeight(.semibold)
                .foregroundColor(Color.newTextColor)
            }
            .frame(width: 100)
            .padding(.vertical, 10)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }
}
