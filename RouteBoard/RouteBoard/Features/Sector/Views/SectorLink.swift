import Foundation
import SwiftUI

struct SectorLink<Content: View>: View {
    @Binding var sectorId: String?
    @ViewBuilder var content: Content

    var body: some View {
        NavigationLink(destination: SectorView(sectorId: sectorId ?? "")) {
            content
        }
    }
}
