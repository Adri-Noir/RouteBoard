// Created with <3 on 20.02.2025.

import SwiftUI

struct NewMainNavigationView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var searchText = ""
  @State private var isSearching = false

  var body: some View {
    NavigationStack {
      ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
        VStack(alignment: .leading, spacing: 15) {
          if searchText == "" {
            Text("Hi, \(authViewModel.user?.username ?? "User")")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)
              .padding(.top, 20)
          }

          TextField("Find Crags, Routes, etc.", text: $searchText)
            .padding()
            .background(Color.white)
            .cornerRadius(10)

          Spacer()
        }
        .padding(.horizontal, 20)
      }
    }
    .accentColor(Color.primaryColor)
  }
}

#Preview {
  AuthInjectionMock {
    NewMainNavigationView()
  }
}
