//
//  SectorClimbTypeView.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import SwiftUI

struct SectorClimbTypeView: View {
  @Binding var climbTypes: [String]

  let climbType = [
    "Crimps", "Jugs", "Vertical", "Slab", "Crack", "Endurance",
  ]
  let climbTypeIcons = [
    "bolt.fill", "hand.thumbsup.fill", "arrow.up.and.down", "arrow.up", "text.book.closed",
    "timer",
  ]

  init(climbTypes: Binding<[String]>) {
    self._climbTypes = climbTypes
  }

  init() {
    self._climbTypes = .constant([])
  }

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
                .foregroundColor(
                  climbTypes.contains(climbType[index % climbType.count])
                    ? Color.white
                    : Color.newTextColor
                )
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

              Text(climbType[index % climbType.count])
                .fontWeight(.semibold)
                .foregroundColor(
                  climbTypes.contains(climbType[index % climbType.count])
                    ? Color.white
                    : Color.newTextColor
                )
            }
            .frame(width: 100)
            .padding(.vertical, 10)
            .background(
              climbTypes.contains(climbType[index % climbType.count])
                ? Color.newPrimaryColor
                : Color.white
            )
            .onTapGesture {
              toggleClimbType(climbType[index % climbType.count])
            }
            .transition(.opacity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }

  private func toggleClimbType(_ type: String) {
    if climbTypes.contains(type) {
      withAnimation {
        climbTypes.removeAll { $0 == type }
      }
    } else {
      withAnimation {
        climbTypes.append(type)
      }
    }
  }
}
