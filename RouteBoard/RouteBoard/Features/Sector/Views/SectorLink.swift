import Foundation
import SwiftUI

struct SectorLink<Content: View>: View {
  @Binding var sectorId: String?
  @ViewBuilder var content: Content

  init(sectorId: Binding<String?>, @ViewBuilder content: @escaping () -> Content) {
    self._sectorId = sectorId
    self.content = content()
  }

  init(sectorId: String?, @ViewBuilder content: @escaping () -> Content) {
    self._sectorId = .constant(sectorId)
    self.content = content()
  }

  var body: some View {
    NavigationLink(destination: SectorView(sectorId: sectorId ?? "")) {
      content
    }
  }
}
