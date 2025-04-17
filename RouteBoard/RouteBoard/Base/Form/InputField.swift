// Created with <3 on 02.04.2025.

import SwiftUI

struct InputField: View {
  let title: String
  @Binding var text: String
  var placeholder: String
  var keyboardType: UIKeyboardType = .default

  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      TextField(
        "", text: $text,
        prompt: Text(placeholder).font(.subheadline).foregroundColor(
          Color.newTextColor.opacity(0.5))
      )
      .keyboardType(keyboardType)
      .padding()
      .background(Color.white)
      .foregroundColor(Color.newTextColor)
      .cornerRadius(10)
      .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
      .focused($isFocused)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .onTapBackground(enabled: isFocused) {
      isFocused = false
    }
  }
}

#Preview {
  InputField(title: "Field Title", text: .constant(""), placeholder: "Enter text here...")
}
