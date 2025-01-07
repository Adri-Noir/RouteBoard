//
//  RouteView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 31.12.2024..
//

import Foundation
import GeneratedClient
import SwiftUI

struct RouteView: View {
  let routeId: String
  @State private var isLoading: Bool = false
  @State private var route: RouteDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel

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

  var body: some View {
    ApplyBackgroundColor {
      DetailsViewStateMachine(details: $route, isLoading: $isLoading) {
        DetectRoutesWrapper {
          ScrollView {
            VStack(alignment: .leading, spacing: 0) {
              ImageCarouselView(imagesNames: routePhotos, height: 500)
                .cornerRadius(20)

              Text(route?.name ?? "Route")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding()

              Text(route?.description ?? "")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.black)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 10))
            }
            .padding()
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
      }
    }
    .task(priority: .userInitiated) {
      await getRoute(value: routeId)
    }
  }
}

#Preview {
  RouteView(routeId: "081f3e29-7072-43a0-5f4d-08dd292795a1")
}
