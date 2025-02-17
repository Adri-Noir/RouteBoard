//
//  RouteView.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import Foundation
import GeneratedClient
import SwiftUI

struct RouteView: View {
  let routeId: String
  @State private var isLoading: Bool = false
  @State private var route: RouteDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  private let getRouteDetailsClient = GetRouteDetailsClient()

  init(routeId: String) {
    self.routeId = routeId
  }

  func getRoute(value: String) async {
    isLoading = true

    guard
      let routeDetails = await getRouteDetailsClient.call(
        RouteDetailsInput(id: value), authViewModel.getAuthData())
    else {
      isLoading = false
      return
    }

    self.route = routeDetails
    isLoading = false
  }

  var routePhotos: [String] {
    route?.routePhotos?.map {
      $0.image?.url ?? ""
    }
    .filter {
      $0 != ""
    } ?? []
  }

  var routeList: [RouteDetails] {
    guard let route = route else {
      return []
    }
    return [route]
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColors: [.newPrimaryColor, .newBackgroundGray]) {
      DetailsViewStateMachine(details: $route, isLoading: $isLoading) {
        RouteTopContainerView(route: route) {
          DetectRoutesWrapper(routes: routeList) {
            ScrollView {
              VStack(spacing: 30) {
                RouteTopInfoContainerView(route: route)
                Spacer()
              }
              .padding(.horizontal, 20)
              .padding(.top, 20)
              .background(Color.newPrimaryColor)

              ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
                VStack(spacing: 20) {
                  Spacer()

                  RouteLocationInfoView(route: route)

                  VStack(spacing: 30) {
                    ImageCarouselView(imagesNames: routePhotos, height: 400)
                      .cornerRadius(20)
                      .padding(.horizontal, 20)
                    SectorClimbTypeView()

                    RouteAscentsView(route: route)

                    Spacer()
                  }
                  .padding(.top, 20)
                  .background(Color.newBackgroundGray)
                  .clipShape(
                    .rect(
                      topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                      topTrailingRadius: 40)
                  )
                }
                .background(.white)
                .clipShape(
                  .rect(
                    topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                    topTrailingRadius: 40)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
                .mask(
                  Rectangle().padding(.top, -40)
                )
              }
            }
          }
        }
      }
    }
    .detailsNavigationBar()
    .task {
      await getRoute(value: routeId)
    }
  }
}

#Preview {
  AuthInjectionMock {
    RouteView(routeId: "ebdabd5e-3a1e-4fa5-f931-08dd3b395c5b")
  }
}
