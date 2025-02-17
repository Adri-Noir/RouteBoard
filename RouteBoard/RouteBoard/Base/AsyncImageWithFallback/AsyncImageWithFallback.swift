//
//  AsyncImageWithFallback.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import SwiftUI

struct AsyncImageWithFallback: View {
  let imageUrl: String?

  var body: some View {
    Group {
      if let image = imageUrl {
        AsyncImage(url: URL(string: image)) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
          case .failure:
            Image("TestingSamples/r3")
              .resizable()
              .scaledToFill()
          @unknown default:
            Image("TestingSamples/r3")
              .resizable()
              .scaledToFill()
          }
        }
      } else {
        Image("TestingSamples/r3")
          .resizable()
          .scaledToFill()
      }
    }
  }
}
