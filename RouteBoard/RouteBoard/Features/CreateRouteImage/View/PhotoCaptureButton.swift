//
//  PhotoCaptureButton.swift
//  RouteBoard
//
//  Created with <3 on 17.12.2024..
//

import SwiftUI

struct PhotoCaptureButton: View {
  private let action: () -> Void
  private let outerLineWidth = CGFloat(3.0)
  private let innerPadding = CGFloat(8.0)

  init(action: @escaping () -> Void) {
    self.action = action
  }

  var body: some View {
    Button {
      action()
    } label: {
      ZStack {
        // Outer circle with border
        Circle()
          .stroke(Color.white, lineWidth: outerLineWidth)

        // Inner solid circle
        Circle()
          .fill(Color.white)
          .padding(innerPadding)
      }
    }
    .buttonStyle(PhotoButtonStyle())
  }

  struct PhotoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
  }
}
