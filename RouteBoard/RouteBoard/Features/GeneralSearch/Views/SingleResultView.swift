import Foundation
import GeneratedClient
import SwiftUI

struct SingleResultView: View {
    @Binding var result: GetSearchResults

    var body: some View {
        HStack {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .padding(2)


            VStack(alignment: .leading) {
                Text(result.name!)
                    .font(.headline)
                Text(result._type!.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
        }
    }
}
