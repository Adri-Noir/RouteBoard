// Created with <3 on 04.03.2025.

import SwiftUI

struct AlertModifier: ViewModifier {
  @Binding var message: String?
  var title: String
  var primaryButtonText: String
  var primaryAction: (() -> Void)?
  var secondaryButtonText: String?
  var secondaryAction: (() -> Void)?

  func body(content: Content) -> some View {
    content
      .alert(
        title,
        isPresented: Binding<Bool>(
          get: { message != nil },
          set: { if !$0 { message = nil } }
        )
      ) {
        Button(primaryButtonText) {
          primaryAction?()
          message = nil
        }

        if let secondaryButtonText = secondaryButtonText {
          Button(secondaryButtonText) {
            secondaryAction?()
            message = nil
          }
        }
      } message: {
        if let message = message {
          Text(message)
        }
      }
  }
}

extension View {
  /// Adds an alert to the view that is shown when the message is not nil
  /// - Parameters:
  ///   - message: The message to display in the alert
  ///   - title: The title of the alert
  ///   - primaryButtonText: The text for the primary button
  ///   - primaryAction: The action to perform when the primary button is tapped
  ///   - secondaryButtonText: The text for the secondary button (optional)
  ///   - secondaryAction: The action to perform when the secondary button is tapped (optional)
  /// - Returns: A view with an alert that shows when the message is not nil
  func alert(
    message: Binding<String?>,
    title: String = "Something went wrong!",
    primaryButtonText: String = "OK",
    primaryAction: (() -> Void)? = nil,
    secondaryButtonText: String? = nil,
    secondaryAction: (() -> Void)? = nil
  ) -> some View {
    self.modifier(
      AlertModifier(
        message: message,
        title: title,
        primaryButtonText: primaryButtonText,
        primaryAction: primaryAction,
        secondaryButtonText: secondaryButtonText,
        secondaryAction: secondaryAction
      ))
  }
}
