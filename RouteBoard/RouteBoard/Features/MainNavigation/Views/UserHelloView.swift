// Created with <3 on 23.02.2025.

import SwiftUI

struct UserHelloView: View {
  @Binding var showProfileView: Bool

  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    HStack {
      HStack(spacing: 4) {
        Text("Hi, \(authViewModel.user?.username ?? "")")
        Text("👋")
          .waving()
      }
      .font(.largeTitle)
      .fontWeight(.bold)
      .foregroundColor(Color.white)
      .transaction { transaction in
        transaction.animation = nil
      }

      Spacer()

      NavigationLink(destination: RegisteredUserView()) {
        Image(systemName: "person.circle.fill")
          .font(.largeTitle)
          .foregroundColor(Color.white)
      }
    }
    .padding(.top, 20)
    .padding(.horizontal, 20)
  }
}
