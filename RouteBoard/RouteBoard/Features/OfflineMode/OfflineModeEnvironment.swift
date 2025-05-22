// Created with <3 on 22.05.2025.

import SwiftUI

private struct OfflineModeKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var isOfflineMode: Bool {
    get { self[OfflineModeKey.self] }
    set { self[OfflineModeKey.self] = newValue }
  }
}

extension View {
  func offlineMode(_ isOffline: Bool) -> some View {
    environment(\.isOfflineMode, isOffline)
  }
}
