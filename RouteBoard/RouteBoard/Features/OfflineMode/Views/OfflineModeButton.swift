// Created with <3 on 18.05.2025.

import SwiftUI

struct OfflineModeButton: View {
  @EnvironmentObject var navigationManager: NavigationManager

  var body: some View {
    Button(action: {
      navigationManager.pushView(.offlineMode)
    }) {
      Label("Offline Mode", systemImage: "airplane")
    }
    .foregroundColor(Color.white)
  }
}
