import Foundation
import SwiftUI

struct DetectRoutesWrapper<Content: View>: View {
    @State private var show: Bool = false;
    @ViewBuilder var content: Content;

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content

            Button {
                show = true
            } label: {
                Image(systemName: "eye")
                    .font(.title.weight(.semibold))
                    .padding()
                    .background(Color.primaryColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding()
            .fullScreenCover(isPresented: $show) {
                RouteFinderView()
            }
        }
    }
}