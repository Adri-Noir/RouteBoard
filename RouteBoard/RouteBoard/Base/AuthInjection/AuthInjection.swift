//
//  AuthInjection.swift
//  RouteBoard
//
//  Created with <3 on 04.01.2025..
//

import SwiftUI

struct AuthInjection<Content: View>: View {
  @ViewBuilder var content: Content
  @StateObject var authViewModel = AuthViewModel()
  @State var showLoading = true

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }

  var body: some View {
    ZStack {
      if showLoading {
        VStack(alignment: .center) {
          VStack {
            Text("Alpinity")
              .font(.largeTitle)
              .fontWeight(.semibold)
              .foregroundStyle(.black)
              .padding()
          }
        }
        .transition(.opacity)
        .onAppear {
          Task {
            await authViewModel.loadUserModel()
            withAnimation {
              showLoading = false
            }
          }
        }
      } else {
        Group {
          if authViewModel.user != nil {
            content
          } else {
            LoginView()
          }
        }
        .transition(.opacity)
        .environmentObject(authViewModel)
        .onAppear {
          Task {
            await authViewModel.loadUserModel()
            showLoading = false
          }
        }
      }
    }
  }
}
