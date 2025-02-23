// Created with <3 on 24.02.2025.

import SwiftUI

struct WaveModifier: ViewModifier {
  public var angle: CGFloat = 20

  @State private var isWaving = false
  @State private var timer: Timer?

  func body(content: Content) -> some View {
    content
      .rotationEffect(.degrees(isWaving ? angle : 0))
      .animation(
        isWaving
          ? .easeInOut(duration: 0.3)
            .repeatForever(autoreverses: true)
          : .easeInOut(duration: 0.3),
        value: isWaving
      )
      .onAppear {
        startWavingCycle()
      }
      .onDisappear {
        timer?.invalidate()
      }
  }

  private func startWavingCycle() {
    timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
      isWaving = true

      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        isWaving = false
      }
    }

    timer?.fire()
  }
}

extension View {
  func waving(angle: CGFloat = 20) -> some View {
    modifier(WaveModifier(angle: angle))
  }
}
