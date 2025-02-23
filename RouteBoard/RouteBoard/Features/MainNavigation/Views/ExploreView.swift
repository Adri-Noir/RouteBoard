// Created with <3 on 23.02.2025.

import SwiftUI

struct ExploreView: View {
  @State private var currentTab = 0
  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "map")
          .foregroundColor(Color.white)
        Text("Explore")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.white)
      }

      TabView(selection: $currentTab) {
        ForEach(0..<5) { index in
          Color.black
            .frame(height: 200)
            .overlay(
              ZStack(alignment: .bottomLeading) {
                Image("TestingSamples/limski/pikachu")
                  .resizable()
                  .scaledToFill()
                  .frame(height: 200)
                  .opacity(0.4)
                  .blur(radius: 1)

                VStack(alignment: .leading) {
                  Text("Crag")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
                .padding()
              }
            )
            .clipped()
            .cornerRadius(10)
            .tag(index)
        }
      }
      .tabViewStyle(.page)
      .frame(height: 200)
      .cornerRadius(10)
      .onReceive(timer) { _ in
        withAnimation {
          currentTab = (currentTab + 1) % 5
        }
      }
    }
    .padding(.horizontal, 20)
  }
}

#Preview {
  ExploreView()
}
