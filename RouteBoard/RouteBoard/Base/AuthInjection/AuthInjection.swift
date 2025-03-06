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

  var loadingView: some View {
    LoadingView()
      .transition(.opacity)
      .onAppear {
        Task {
          await authViewModel.loadUserModel()
          withAnimation {
            showLoading = false
          }
        }
      }
  }

  var contentOrLoginView: some View {
    Group {
      if authViewModel.user != nil {
        content
          .transition(.move(edge: .trailing))
      } else {
        LoginView()
          .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
      }
    }
    .environmentObject(authViewModel)
    .onAppear {
      Task {
        await authViewModel.loadUserModel()
      }
    }
  }

  var body: some View {
    ZStack {
      if showLoading {
        loadingView
      } else {
        contentOrLoginView
      }
    }
    .onDisappear {
      authViewModel.cancelRequests()
    }
  }
}

private struct LoadingView: View {
  var body: some View {
    VStack(alignment: .center) {
      VStack {
        Text("Alpinity")
          .font(.largeTitle)
          .fontWeight(.semibold)
          .foregroundStyle(.black)
          .padding()
      }
    }
  }
}
