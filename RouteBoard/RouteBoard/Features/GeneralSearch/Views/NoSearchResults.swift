import Foundation
import SwiftUI

struct NoSearchResultsView: View {
  var body: some View {
    VStack {
      Spacer()
      Image(systemName: "magnifyingglass.circle")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.white)
      Text("No Search Results")
        .font(.headline)
        .foregroundColor(.white)
        .padding(.top)
      Text("Try searching for a different crag, sector, route or user.")
        .font(.subheadline)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .padding(.top, 2)
        .padding(.horizontal, 20)
      Spacer()
    }
    .padding()
  }
}
