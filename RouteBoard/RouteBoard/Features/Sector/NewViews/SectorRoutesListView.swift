//
//  SectorRoutesListView.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import GeneratedClient
import SwiftUI

private struct SectorRoute: View {
  let route: RouteDetails

  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    RouteLink(routeId: route.id) {
      VStack(spacing: 0) {
        Color.newBackgroundGray
          .frame(height: 200)
          .overlay(
            AsyncImageWithFallback(imageUrl: route.routePhotos?.first?.image?.url)
          ).clipped()

        VStack {
          MarqueeText(
            text: route.name ?? "Route",
            font: UIFont.preferredFont(forTextStyle: .body),
            leftFade: 10,
            rightFade: 10,
            startDelay: 3,
            alignment: .center
          )
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)

          Text(authViewModel.getGradeSystem().convertGradeToString(route.grade))
            .foregroundColor(Color.newTextColor.opacity(0.7))
        }
        .padding(.top, 10)
      }
      .frame(width: UIScreen.main.bounds.width / 2 - 30)
      .padding(.bottom, 10)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
  }
}

struct SectorRoutesList: View {
  var routes: [RouteDetails] = []

  init(sector: SectorDetails?) {
    self.routes = sector?.routes ?? []
  }

  var title: some View {
    HStack(alignment: .center) {
      Text("Routes")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)

      Spacer()

      Button {
        print("Search")
      } label: {
        Image(systemName: "magnifyingglass")
          .font(.title2)
          .foregroundColor(Color.newTextColor)
      }
    }
    .padding(.horizontal, 20)
  }

  var body: some View {
    VStack {
      title

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 20) {
          ForEach(routes, id: \.id) { route in
            SectorRoute(route: route)
          }
        }
        .padding(.horizontal, 20)
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollTargetLayout()
    }
  }
}
