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
                .foregroundColor(.gray)
            Text("No Search Results")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top)
            Text("Try adjusting your keywords or filters to find what you're looking for.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
                .padding(.horizontal, 20)
            Spacer()
        }
        .padding()
    }
}