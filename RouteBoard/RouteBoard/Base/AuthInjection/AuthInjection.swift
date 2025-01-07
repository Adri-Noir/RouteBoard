//
//  AuthInjection.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.01.2025..
//

import SwiftUI

struct AuthInjection<Content: View>: View {
  @ViewBuilder var content: Content
  @StateObject var authViewModel = AuthViewModel()
  @State var showLoading = true

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
          Task(priority: .userInitiated) {
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
          Task(priority: .userInitiated) {
            await authViewModel.loadUserModel()
            showLoading = false
          }
        }
      }
    }
  }
}
