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

  @State private var isPresentingCreateRouteImageView = false
  @State private var isPresentingRouteLogAscent = false

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  private let getRouteDetailsClient = GetRouteDetailsClient()
  private let imageSize: CGFloat = 300

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

  var routeList: [RouteDetails] {
    guard let route = route else {
      return []
    }
    return [route]
  }

  var body: some View {
    ApplyBackgroundColor(
      backgroundColor: Color.newBackgroundGray
    ) {
      DetailsViewStateMachine(details: $route, isLoading: $isLoading) {
        DetectRoutesWrapper(routes: routeList) {
          RouteHeaderView(route: route, isPresentingRouteLogAscent: $isPresentingRouteLogAscent) {
            VStack(spacing: 0) {
              RouteTopInfoContainerView(route: route)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(Color.newPrimaryColor)

              VStack(spacing: 20) {
                RouteLocationInfoView(route: route)
                  .padding(.top, 20)

                VStack(spacing: 30) {
                  SectorClimbTypeView(route: route)
                  RouteAscentsView(route: route)
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
              .background(Color.newPrimaryColor)

            }
          }
        }
      }
    }
    .fullScreenCover(isPresented: $isPresentingCreateRouteImageView) {
      CreateRouteImageView()
    }
    .sheet(isPresented: $isPresentingRouteLogAscent) {
      RouteLogAscent(
        route: route,
        onAscentLogged: {
          Task {
            await getRoute(value: routeId)
          }
        })
    }
    .task {
      await getRoute(value: routeId)
    }
    .navigationBarHidden(true)
  }
}

#Preview {
  AuthInjectionMock {
    RouteView(routeId: "fd5eb7b6-734b-458d-b7e5-08dd56b8e84e")
  }
}
