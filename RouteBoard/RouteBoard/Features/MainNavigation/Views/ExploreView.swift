// Created with <3 on 23.02.2025.

import SwiftUI

struct ExploreView: View {
  @State private var currentTab: String? = "0"
  @Namespace private var scrollSpace
  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Image(systemName: "map")
          .foregroundColor(Color.white)
        Text("Explore")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.white)
      }
      .padding(.horizontal, 20)

      ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
          ForEach(0..<5) { index in
            GeometryReader { geometry in
              ZStack(alignment: .bottomLeading) {
                Image("TestingSamples/limski/pikachu")
                  .resizable()
                  .scaledToFill()
                  .frame(width: geometry.size.width, height: geometry.size.height)

                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.2),
                  ]),
                  startPoint: .bottom,
                  endPoint: .top
                )

                VStack(alignment: .leading) {
                  Text("Crag")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
                .padding()
              }
              .frame(width: geometry.size.width, height: geometry.size.height)
              .cornerRadius(10)
              .scrollTransition { content, phase in
                content
                  .opacity(phase.isIdentity ? 1 : 0.5)
                  .scaleEffect(phase.isIdentity ? 1 : 0.9)
                  .blur(radius: phase.isIdentity ? 0 : 5)
              }
            }
            .padding(.horizontal, 20)
            .containerRelativeFrame(.horizontal, count: 1, spacing: 0, alignment: .center)
            .padding(.vertical, 10)
            .id("\(index)")
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $currentTab)
      .scrollTargetBehavior(.viewAligned)
      .scrollIndicators(.hidden)
      .frame(height: 250)
      .onScrollVisibilityChange { _ in
        timer.upstream.connect().cancel()
      }
      .onReceive(timer) { _ in
        withAnimation(.easeInOut(duration: 0.5)) {
          if let current = currentTab, let currentInt = Int(current) {
            currentTab = "\((currentInt + 1) % 5)"
          } else {
            currentTab = "0"
          }
        }
      }
    }
  }
}

#Preview {
  AuthInjectionMock {
    ExploreView()
  }
}
