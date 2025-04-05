// Created with <3 on 02.04.2025.

import SwiftUI

struct TextAreaField: View {
  let title: String
  @Binding var text: String
  var placeholder: String
  var minHeight: CGFloat = 120
  var padding: CGFloat?

  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, padding)

      ZStack(alignment: .topLeading) {
        TextEditor(text: $text)
          .frame(minHeight: minHeight)
          .scrollContentBackground(.hidden)
          .focused($isFocused)
          .padding(5)
          .foregroundColor(Color.newTextColor)
          .overlay(
            text.isEmpty
              ? Text(placeholder)
                .font(.subheadline)
                .foregroundColor(Color.newTextColor.opacity(0.5))
                .padding(12)
                .allowsHitTesting(false)
              : nil,
            alignment: .topLeading
          )
      }
      .background(Color.white)
      .cornerRadius(10)
      .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
      .padding(.horizontal, padding)
    }
    .onTapBackground(enabled: isFocused) {
      isFocused = false
    }
  }
}

#Preview {
  TextAreaField(title: "Description", text: .constant(""), placeholder: "Enter description here...")
}
