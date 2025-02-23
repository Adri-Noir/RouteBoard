import Foundation
import GeneratedClient
import SwiftUI

struct SingleResultView: View {
  @Binding var result: GetSearchResults

  var body: some View {
    HStack(spacing: 12) {
      Image("TestingSamples/limski/pikachu")
        .resizable()
        .scaledToFill()
        .frame(width: 65, height: 65)
        .cornerRadius(10)

      VStack(alignment: .leading) {
        Text(result.name!)
          .font(.headline)
          .foregroundColor(Color.newTextColor)
        Text(result._type!.rawValue)
          .font(.subheadline)
          .foregroundColor(Color.newTextColor)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(Color.white)
    .cornerRadius(10)
    .shadow(color: Color.white.opacity(0.4), radius: 25, x: 0, y: 0)
  }
}
