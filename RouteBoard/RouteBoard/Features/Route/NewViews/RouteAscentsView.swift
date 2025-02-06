//
//  RouteAscentsView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 26.01.2025..
//

import GeneratedClient
import SwiftUI

private struct RouteAscentRowView: View {
  var body: some View {
    HStack(spacing: 15) {
      Image(systemName: "person.circle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 60)
        .foregroundColor(Color.newTextColor)

      VStack(alignment: .leading, spacing: 5) {
        Text("Adrian Cvijanovic")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)

        Text("7c")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)
      }

      Spacer()

      VStack {
        Spacer()

        Text("Redpoint")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundColor(Color.white)
          .padding(5)
          .background(Color.newPrimaryColor)
          .cornerRadius(5)

        Spacer()
      }
    }
    .padding(10)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .padding(.horizontal, 20)
  }
}

struct RouteAscentsView: View {
  var route: RouteDetails?

  @State private var currentIndex = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Ascents (12)")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, 20)

      TabView(selection: $currentIndex) {
        ForEach(0..<3) { _ in
          VStack(spacing: 15) {
            ForEach(0..<4) { _ in
              RouteAscentRowView()
            }
          }
        }
      }
      .tabViewStyle(.page)
      .indexViewStyle(
        .page(backgroundDisplayMode: .always)
      )
      .frame(height: 450)
    }
  }
}
