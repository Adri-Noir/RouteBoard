//
//  DetailsTopView.swift
//  RouteBoard
//
//  Created with <3 on 19.01.2025..
//

import SwiftUI

struct DetailsTopView: View {
  let pictures: [String]

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack(alignment: .top) {
      ImageCarouselView(imagesNames: pictures, height: 500)
        .cornerRadius(20)

      HStack {
        Button(action: {
          dismiss()
        }) {
          Image(systemName: "chevron.left")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .frame(width: 50, height: 50)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }

        Spacer()

        Button(action: {
          print("Button tapped")
        }) {
          Image(systemName: "heart")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .frame(width: 50, height: 50)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
      }
      .padding(.horizontal, 20)
      .padding(
        .top,
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?
          .safeAreaInsets.top ?? 0)
    }
  }
}
