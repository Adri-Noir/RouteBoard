// Created with <3 on 13.04.2025.

import SwiftUI

struct LogoutButton: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    Button(action: {
      Task {
        await authViewModel.logout()
      }
    }) {
      HStack {
        Spacer()
        Image(systemName: "person.crop.circle.fill.badge.xmark")
        Text("Logout")
        Spacer()
      }
      .padding()
      .background(Color.newBackgroundGray)
      .cornerRadius(10)
      .foregroundColor(Color.newTextColor)
    }
  }
}

#Preview {
  AuthInjectionMock {
    LogoutButton()
  }
}
