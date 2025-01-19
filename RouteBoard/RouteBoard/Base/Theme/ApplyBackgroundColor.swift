//
//  ApplyBackgroundColor.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI

struct ApplyBackgroundColor<Content: View>: View {
  @ViewBuilder var content: Content

  var body: some View {
    ZStack {
      Color.backgroundPrimary.ignoresSafeArea()

      content
    }
  }
}
