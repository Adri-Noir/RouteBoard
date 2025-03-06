//
//  AuthInjectionMock.swift
//  RouteBoard
//
//  Created with <3 on 16.01.2025..
//

import SwiftUI

struct AuthInjectionMock<Content: View>: View {
  @ViewBuilder var content: Content
  @StateObject var authViewModel = AuthViewModel()

  @State var delayContent = true

  var body: some View {
    ZStack {
      if !delayContent {
        content
          .environmentObject(authViewModel)
      }
    }
    .task {
      await authViewModel.loginWithSeededUser()
      delayContent = false
    }
    .onDisappear {
      authViewModel.cancelRequests()
    }
  }
}
