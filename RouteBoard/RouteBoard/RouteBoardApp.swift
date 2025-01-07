//
//  RouteBoardApp.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import SwiftUI
import os

@main
struct RouteBoardApp: App {
  init() {
    UINavigationBar.applyCustomAppearance()
  }

  var body: some Scene {
    WindowGroup {
      AuthInjection {
        MainNavigation()
      }
    }
  }
}

extension UINavigationBar {

  fileprivate static func applyCustomAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    appearance.backgroundColor = UIColor(Color.backgroundPrimary)
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}

let logger = Logger()
