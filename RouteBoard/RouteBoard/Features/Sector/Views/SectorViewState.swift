import Foundation
import SwiftUI
import GeneratedClient

struct SectorViewState<Content: View>: View {
    @Binding var sectorDetails: SectorDetails?
    @Binding var isLoading: Bool
    @ViewBuilder var content: Content

    var body: some View {
        if isLoading {
            VStack {
                ProgressView().tint(.black)
            }
        } else if sectorDetails == nil {
            VStack {
                Text("Not Found")
                    .foregroundColor(.black)
            }
        } else {
            content
        }
    }
}
