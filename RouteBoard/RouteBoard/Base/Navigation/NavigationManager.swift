// Created with <3 on 05.04.2025.

import SwiftUI

class NavigationManager: ObservableObject {

   @Published var routes: [NavigationPaths] = []

   func pushView(_ newView: NavigationPaths) {
      routes.append(newView)
   }

   func popToRoot() {
      self.routes.removeAll()
   }

   func pop() {
      self.routes.removeLast()
   }

   func popUntil(_ targetRoute: NavigationPaths) {
      if self.routes.last != targetRoute {
         self.routes.removeLast()
         popUntil(targetRoute)
      }
   }
}
