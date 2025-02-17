//
//  ImageCarouselView.swift
//  RouteBoard
//
//  Created with <3 on 02.07.2024..
//

import SwiftUI

struct ImageCarouselView: View {
  var imagesNames: [String]
  var height: CGFloat = 300
  @State private var currentIndex = 0

  init(imagesNames: [String], height: CGFloat) {
    self.imagesNames = imagesNames
    self.height = height
  }

  init(imagesNames: [String]) {
    self.imagesNames = imagesNames
  }

  var body: some View {
    ZStack {
      Color.newBackgroundGray

      TabView(selection: $currentIndex) {
        ForEach(0..<imagesNames.count, id: \.self) { index in
          AsyncImageWithFallback(imageUrl: imagesNames[index])
            .tag(index)
        }
      }
      .tabViewStyle(.page)
      .indexViewStyle(
        .page(backgroundDisplayMode: .always)
      )
      // .padding()
    }
    .frame(height: height)
  }

}

#Preview {
  ImageCarouselView(imagesNames: ["TestingSamples/r3", "TestingSamples/r2"])
}
