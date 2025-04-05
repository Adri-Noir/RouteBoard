import Foundation
import SwiftUI

struct SectorLink<Content: View>: View {
  @Binding var sectorId: String?
  @ViewBuilder var content: Content

  @EnvironmentObject var navigationManager: NavigationManager

  init(sectorId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._sectorId = sectorId
    self.content = content()
  }

  init(sectorId: String?, @ViewBuilder content: @escaping () -> Content) {
    self._sectorId = .constant(sectorId)
    self.content = content()
  }

  var body: some View {
    Button(action: {
      navigationManager.pushView(.sectorDetails(sectorId: sectorId ?? ""))
    }) {
      content
    }
  }
}
