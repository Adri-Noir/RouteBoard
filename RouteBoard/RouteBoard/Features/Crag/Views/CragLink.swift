//
//  CragLink.swift
//  RouteBoard
//
//  Created with <3 on 01.01.2025..
//

import SwiftUI

struct CragLink<Content: View>: View {
  @Binding var cragId: String?
  @ViewBuilder var content: Content

  @EnvironmentObject var navigationManager: NavigationManager

  init(cragId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._cragId = cragId
    self.content = content()
  }

  init(cragId: String, @ViewBuilder content: @escaping () -> Content) {
    self._cragId = .constant(cragId)
    self.content = content()
  }

  var body: some View {
    Button(action: {
      navigationManager.pushView(.cragDetails(id: cragId ?? ""))
    }) {
      content
    }
  }
}
