//
//  ApplyBackgroundColor.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI

struct ApplyBackgroundColor<Content: View>: View {
    var backgroundColor: [Color] = [Color.newBackgroundGray]
  @ViewBuilder var content: Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }

  init(backgroundColor: Color, @ViewBuilder content: @escaping () -> Content) {
    self.backgroundColor = [backgroundColor]
    self.content = content()
  }

  init(backgroundColors: [Color], @ViewBuilder content: @escaping () -> Content) {
    self.backgroundColor = backgroundColors
    self.content = content()
  }

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        ForEach(backgroundColor, id: \.self) { color in
          color
            .ignoresSafeArea()
        }
      }

      content
    }
  }
}
