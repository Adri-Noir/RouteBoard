import Foundation
import SwiftUI

struct SlideupLayout<Content: View>: View {
  @ViewBuilder var content: Content

  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Spacer()
        Capsule()
          .fill(Color.newPrimaryColor)
          .frame(width: 40, height: 10)
        Spacer()
      }
      .padding(.top, 20)

      content
    }
    .clipShape(
      .rect(
        topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
        topTrailingRadius: 40, style: .continuous))
  }
}
