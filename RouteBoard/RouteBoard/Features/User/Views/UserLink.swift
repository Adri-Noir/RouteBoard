// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct UserLink<Content: View>: View {
  @Binding var userId: String?
  @ViewBuilder var content: Content

  @EnvironmentObject var navigationManager: NavigationManager

  init(userId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._userId = userId
    self.content = content()
  }

  init(userId: String, @ViewBuilder content: @escaping () -> Content) {
    self._userId = .constant(userId)
    self.content = content()
  }

  var body: some View {
    if let userId = userId {
      Button(action: {
        navigationManager.pushView(.userDetails(id: userId))
      }) {
        content
      }
    }
  }
}
