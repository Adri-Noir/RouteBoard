//
//  CragGalleryView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

private struct ImageGalleryView: View {
  let images: [Image]

  var body: some View {
    TabView {
      ForEach(images.indices, id: \.self) { index in
        images[index]
          .resizable()
          .scaledToFit()
      }
    }
    .tabViewStyle(PageTabViewStyle())
  }
}

struct CragGalleryView: View {
  let crag: CragDetails?

  @State private var isModalPresented = false
  private var images = [
    Image("TestingSamples/r1"), Image("TestingSamples/r2"), Image("TestingSamples/r3"),
    Image("TestingSamples/r4"),
  ]

  init(crag: CragDetails?) {
    self.crag = crag
  }

  var title: some View {
    Text("Gallery")
      .font(.title2)
      .fontWeight(.bold)
      .foregroundColor(Color.newTextColor)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      title

      LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 5
      ) {
        ForEach(0..<images.count, id: \.self) { index in
          Color.newBackgroundGray
            .aspectRatio(1, contentMode: .fill)
            .overlay(
              images[index]
                .resizable()
                .scaledToFill()
            ).clipped()
            .cornerRadius(10)
        }
      }
      .onTapGesture {
        isModalPresented = true
      }
      .sheet(isPresented: $isModalPresented) {
        ImageGalleryView(images: images)
      }
    }
  }
}
