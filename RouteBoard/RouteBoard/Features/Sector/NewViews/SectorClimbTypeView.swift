//
//  SectorClimbTypeView.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import GeneratedClient
import SwiftUI

struct SectorClimbTypeView: View {
  @Binding var climbTypes: [UserClimbingType]
  let route: RouteDetails?

  let climbTypeIcons = [
    // ClimbType icons
    "timer", "bolt.fill", "brain.head.profile",

    // RockType icons
    "arrow.up.and.down", "arrow.down.forward", "arrow.down", "arrow.up", "arrowtriangle.right.fill",
    "triangle.fill",

    // HoldType icons
    "text.book.closed", "bolt.fill", "hand.raised.fingers.spread", "hand.point.up.left",
    "hand.thumbsup.fill", "circle.grid.3x3.fill",
  ]

  init(climbTypes: Binding<[UserClimbingType]>) {
    self._climbTypes = climbTypes
    self.route = nil
  }

  init() {
    self._climbTypes = .constant([])
    self.route = nil
  }

  init(route: RouteDetails?) {
    self._climbTypes = .constant([])
    self.route = route
  }

  var allClimbingTypes: [UserClimbingType] {
    if let route = route {
      return route.ascents?.flatMap { ascent in
        ClimbTypesConverter.convertComponentsClimbTypesToUserClimbingTypes(
          componentsClimbTypes: ascent.climbTypes ?? []
        )
          + ClimbTypesConverter.convertComponentsRockTypesToUserClimbingTypes(
            componentsRockTypes: ascent.rockTypes ?? []
          )
          + ClimbTypesConverter.convertComponentsHoldTypesToUserClimbingTypes(
            componentsHoldTypes: ascent.holdTypes ?? []
          )
      } ?? []
    }
    return ClimbTypesConverter.allClimbingTypes
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
          ForEach(Array(zip(allClimbingTypes.indices, allClimbingTypes)), id: \.0) {
            index, climbType in
            climbTypeButton(climbType: climbType, iconIndex: index)
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }

  private func climbTypeButton(climbType: UserClimbingType, iconIndex: Int) -> some View {
    let isSelected = climbTypes.contains { $0 == climbType }

    return VStack(spacing: 0) {
      Image(systemName: climbTypeIcons[iconIndex % climbTypeIcons.count])
        .font(.title)
        .foregroundColor(isSelected ? Color.white : Color.newTextColor)
        .frame(width: 50, height: 50)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

      Text(climbType.rawValue)
        .fontWeight(.semibold)
        .foregroundColor(isSelected ? Color.white : Color.newTextColor)
    }
    .frame(width: 100)
    .padding(.vertical, 10)
    .background(isSelected ? Color.newPrimaryColor : Color.white)
    .onTapGesture {
      toggleClimbType(climbType)
    }
    .transition(.opacity)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }

  private func toggleClimbType(_ type: UserClimbingType) {
    if let index = climbTypes.firstIndex(where: { $0 == type }) {
      withAnimation {
        climbTypes.remove(at: index)
      }
    } else {
      withAnimation {
        climbTypes.append(type)
      }
    }
  }
}
