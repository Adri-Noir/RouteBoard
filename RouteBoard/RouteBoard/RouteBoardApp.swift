//
//  RouteBoardApp.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import SwiftUI
import os

@main
struct RouteBoardApp: App {
  var body: some Scene {
    WindowGroup {
      AuthInjection {
        MainNavigation()
      }
    }
  }
}

let logger = Logger()

#Preview {
  AuthInjection {
    MainNavigation()
  }
}
