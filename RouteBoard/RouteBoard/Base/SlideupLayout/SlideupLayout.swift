import Foundation
import SwiftUI

struct SlideupLayout<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.backgroundGray)
                    .frame(width: 40, height: 10)
                Spacer()
            }

            content
        }
        .padding(10)
    }
}
