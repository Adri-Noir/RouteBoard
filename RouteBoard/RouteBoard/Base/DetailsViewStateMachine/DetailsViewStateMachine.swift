import Foundation
import SwiftUI

struct DetailsViewStateMachine<DetailType, Content: View>: View {
    @Binding var details: DetailType?
    @Binding var isLoading: Bool
    @ViewBuilder var content: Content

    
    var body: some View {
        if isLoading {
            VStack {
                ProgressView().tint(.black)
            }
        } else if details == nil {
            VStack {
                Text("Not Found")
                    .foregroundColor(.black)
            }
        } else {
            content
        }
    }
}
