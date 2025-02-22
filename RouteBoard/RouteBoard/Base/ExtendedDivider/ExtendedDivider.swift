//
//  ExtendedDivider.swift
//  RouteBoard
//
//  Created with <3 on 02.07.2024..
//

import SwiftUI

struct ExtendedDivider: View {
  var width: CGFloat = 2
  var direction: Axis.Set = .horizontal
  @Environment(\.colorScheme) var colorScheme
  var body: some View {
    ZStack {
      Rectangle()
        .fill(
          colorScheme == .dark
            ? Color(red: 0.278, green: 0.278, blue: 0.290)
            : Color(red: 0.706, green: 0.706, blue: 0.714)
        )
        .applyIf(direction == .vertical) {
          $0.frame(width: width)
            .edgesIgnoringSafeArea(.vertical)
        } else: {
          $0.frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
  }
}

extension View {
  @ViewBuilder func applyIf<T: View>(
    _ condition: @autoclosure () -> Bool, apply: (Self) -> T, else: (Self) -> T
  ) -> some View {
    if condition() {
      apply(self)
    } else {
      `else`(self)
    }
  }
}

#Preview {
  ExtendedDivider()
}
