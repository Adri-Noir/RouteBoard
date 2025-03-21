import Foundation
import SwiftUI

struct DetailsViewStateMachine<DetailType, Content: View>: View {
  @Binding var details: DetailType?
  @Binding var isLoading: Bool
  @ViewBuilder var content: Content

  var body: some View {
    if isLoading {
      VStack(spacing: 20) {
        Spacer()
        ProgressView()
          .scaleEffect(1.5)
          .tint(.white)

        Text("Loading...")
          .font(.headline)
          .foregroundColor(.white)
          .opacity(0.8)
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .ignoresSafeArea()
      .background(Color.newPrimaryColor)
      .transition(.opacity)
    } else if details == nil {
      VStack(spacing: 16) {
        Spacer()

        Image(systemName: "exclamationmark.triangle")
          .font(.system(size: 50))
          .foregroundColor(.white.opacity(0.8))

        Text("Not Found")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.white)

        Text("The requested information could not be found.")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)

        Spacer()
      }
      .frame(maxWidth: .infinity)
      .ignoresSafeArea()
      .background(Color.newPrimaryColor)
      .transition(.opacity)
    } else {
      content
    }
  }
}
