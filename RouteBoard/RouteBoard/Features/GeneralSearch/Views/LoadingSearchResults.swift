import Foundation
import SwiftUI

struct LoadingSearchResultsView: View {
  var body: some View {
    VStack {
      ProgressView("Loading...")
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .foregroundColor(.white)
        .padding()
      Text("Fetching search results, please wait.")
        .font(.subheadline)
        .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .edgesIgnoringSafeArea(.all)
  }
}
