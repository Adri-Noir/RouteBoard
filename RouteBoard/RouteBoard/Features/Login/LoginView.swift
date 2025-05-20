//
//  LoginView.swift
//  RouteBoard
//
//  Created with <3 on 02.01.2025..
//

import GeneratedClient
import SwiftUI

struct LoginView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var loginIsOpen: Bool = false

  var body: some View {
    Navigator { manager in
      ApplyBackgroundColor(backgroundColor: Color.black) {
        ZStack(alignment: .bottom) {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(0.3)
            .ignoresSafeArea()

          VStack(alignment: .center) {
            Text("Hello there 👋")
              .font(.title)
              .foregroundColor(.white)
              .padding(.bottom, 30)

            Button(action: {
              manager.pushView(.login)
            }) {
              if loginIsOpen {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .frame(width: UIScreen.main.bounds.width - 80, height: 30)
                  .foregroundColor(.white)
                  .padding()
                  .background(Color.newPrimaryColor)
                  .cornerRadius(10)
              } else {
                Text("Login")
                  .frame(width: UIScreen.main.bounds.width - 80, height: 30)
                  .foregroundColor(.white)
                  .padding()
                  .background(Color.newPrimaryColor)
                  .cornerRadius(10)
                  .fontWeight(.bold)
                  .font(.title3)
              }
            }
            .disabled(loginIsOpen)
            .padding(.bottom, 10)

            Button(action: {
              manager.pushView(.register)
            }) {
              Text("Register")
                .frame(width: UIScreen.main.bounds.width - 80, height: 30)
                .foregroundColor(Color.newPrimaryColor)
                .padding()
                .background(Color.newBackgroundGray)
                .cornerRadius(10)
                .fontWeight(.bold)
                .font(.title3)
            }
            .disabled(loginIsOpen)
            .padding(.bottom)

            OfflineModeButton()

            Spacer()
              .frame(height: 150)
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
        }
      }
    }
  }
}

#Preview {
  AuthInjection {
    LoginView()
  }
}
