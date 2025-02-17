//
//  UINavigationBarExtension.swift
//  RouteBoard
//
//  Created with <3 on 25.01.2025..
//

import SwiftUI

extension UINavigationBar {

  static func applyCustomAppearance() -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    appearance.backgroundColor = UIColor(Color.newPrimaryColor)

    appearance.titleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 20, weight: .bold),
      .foregroundColor: UIColor.white,
    ]

    appearance.shadowColor = .clear

    return appearance
  }
}

extension View {
  func detailsNavigationBar() -> some View {
    self.modifier(DetailsNavigationBar())
  }
}

struct DetailsNavigationBar: ViewModifier {
  init() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    appearance.backgroundColor = UIColor(Color.newPrimaryColor)

    appearance.titleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 20, weight: .bold),
      .foregroundColor: UIColor.white,
    ]

    appearance.shadowColor = .clear
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
  }

  func body(content: Content) -> some View {
    content
  }
}
