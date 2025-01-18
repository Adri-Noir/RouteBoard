import Foundation
import SwiftUI

struct MainNavigationWithFloatingSearch<Content: View>: View {
  @ViewBuilder var content: Content

  @State var showSearchView: Bool = false

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottom) {
        content

        HStack {
          Spacer()
            .frame(width: 30)

          Button(action: {
            print("Button tapped")
          }) {
            Image(systemName: "house")
              .foregroundColor(.white)
              .padding(25)
              .clipShape(Circle())
              .font(.title2)
          }
          .padding(.vertical, 5)

          Spacer()

          Spacer()

          Button(action: {
            print("Button tapped")
          }) {
            Image(systemName: "gear")
              .foregroundColor(.white)
              .padding(25)
              .clipShape(Circle())
              .font(.title2)
          }
          .padding(.vertical, 5)

          Spacer()
            .frame(width: 30)
        }
        .background(Color.primaryColor)
        .clipShape(Capsule())
        .padding(.horizontal, 10)
        .overlay(
          Button(action: {
            showSearchView.toggle()
          }) {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.white)
              .padding(35)
              .background(Circle().fill(Color.buttonPrimary))
              .font(.title2)
            // TODO: fix issue when main navigation search button is clicked background color is shown
          }
          .clipShape(Circle())
          .overlay(
            Circle()
              .strokeBorder(Color.backgroundPrimary, lineWidth: 7)
          )
          .popover(isPresented: $showSearchView) {
            GeneralSearchView()
          }
          .offset(y: -30),
          alignment: .center
        )
        .background(Color.backgroundPrimary)
      }
    }
  }
}
