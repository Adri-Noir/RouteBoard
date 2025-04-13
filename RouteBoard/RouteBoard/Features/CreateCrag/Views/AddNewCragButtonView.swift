// Created with <3 on 31.03.2025.

import SwiftUI

struct AddNewCragButtonView: View {
  @State private var isPresentingCreateCragView = false

  var body: some View {
    Button(
      action: {
        isPresentingCreateCragView = true
      },
      label: {
        HStack {
          Spacer()
          Text("Add New Crag")
            .foregroundColor(Color.newTextColor)
          Spacer()
        }
        .padding(.vertical)
        .background(Color.newBackgroundGray)
        .foregroundColor(Color.newTextColor)
        .cornerRadius(10)
      }
    )
    .fullScreenCover(isPresented: $isPresentingCreateCragView) {
      CreateCragView()
    }
  }
}
