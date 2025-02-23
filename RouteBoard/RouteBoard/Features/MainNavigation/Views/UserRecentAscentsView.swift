// Created with <3 on 23.02.2025.

import SwiftUI

struct UserRecentAscentsView: View {
  var body: some View {
    VStack {
      HStack(alignment: .center) {
        Image(systemName: "figure.climbing")
          .foregroundColor(Color.white)

        Text("Recent ascents")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.white)

        Spacer()

        Button(action: {
          // Action to show all recently ascended routes
        }) {
          Text("Show All")
            .font(.caption2)
            .foregroundColor(.white)
        }
      }
      .padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 20) {
          ForEach(0..<5) { _ in
            VStack(spacing: 0) {
              Color.black
                .frame(height: 225)
                .overlay(
                  ZStack(alignment: .topLeading) {
                    Image("TestingSamples/limski/pikachu")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .opacity(0.4)
                      .blur(radius: 1)

                    VStack(alignment: .leading) {
                      HStack(alignment: .center) {
                        Text("Route Name")
                          .font(.title2)
                          .fontWeight(.bold)
                          .foregroundColor(Color.white)

                        Text("6a")
                          .font(.subheadline)
                          .foregroundColor(Color.white)
                      }
                      .padding(.horizontal, 10)
                      .padding(.top, 30)

                      Spacer()

                      VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                          // Action to show crag details
                        }) {
                          Text("Crag")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                        Button(action: {
                          // Action to show sector details
                        }) {
                          Text("Sector")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                      }
                      .padding(.horizontal, 10)
                      .padding(.bottom, 10)
                    }
                  }
                )
                .clipped()
            }
            .frame(width: UIScreen.main.bounds.width / 2 - 30)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          }
        }
        .padding(.horizontal, 20)
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollTargetLayout()
    }
  }
}
