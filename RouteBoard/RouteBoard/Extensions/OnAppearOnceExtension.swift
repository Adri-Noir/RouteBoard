// Created with <3 on 13.03.2025.

import SwiftUI

extension View {
  func onAppearOnce(perform action: @escaping () -> Void) -> some View {
    modifier(OnAppearOnceModifier(action: action))
  }
}

private struct OnAppearOnceModifier: ViewModifier {
  @State private var hasAppeared = false
  let action: () -> Void

  func body(content: Content) -> some View {
    content
      .onAppear {
        if !hasAppeared {
          hasAppeared = true
          action()
        }
      }
  }
}
