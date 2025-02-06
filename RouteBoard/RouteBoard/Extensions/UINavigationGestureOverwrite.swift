//
//  UINavigationGestureOverrite.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 19.01.2025..
//

import SwiftUI

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
