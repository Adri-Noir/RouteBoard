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
  @State private var scrollOffset: CGFloat = 0
  @State private var startingScrollOffset: CGFloat = 0

  private let imageCollapseThreshold: CGFloat = 350
  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

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

  var navigationImageSize: CGFloat {
    if scrollOffset > startingScrollOffset {
      return max(imageCollapseThreshold - (scrollOffset - startingScrollOffset), 0)
    }
    return imageCollapseThreshold + max(-scrollOffset + startingScrollOffset, 0)
  }

  var navbarOpacity: Double {
    let startFadeIn = imageCollapseThreshold * 0.5

    if scrollOffset <= startFadeIn {
      return 0.0
    } else if scrollOffset >= imageCollapseThreshold {
      return 1.0
    } else {
      return Double((scrollOffset - startFadeIn) / (imageCollapseThreshold - startFadeIn))
    }
  }

  var navigationBarExpanded: some View {
    AsyncImage(url: URL(string: routePhotos.first ?? "")) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(height: navigationImageSize)
        .clipped()
        .allowsHitTesting(false)

    } placeholder: {
      Image("TestingSamples/limski/pikachu")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(height: navigationImageSize)
        .clipped()
    }
  }

  var compactNavigationBar: some View {
    HStack {
      Button(action: {
        dismiss()
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(8)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }

      Spacer()

      if let routePhoto = routePhotos.first, !routePhoto.isEmpty {
        AsyncImage(url: URL(string: routePhoto)) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } placeholder: {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .scaledToFill()
            .foregroundColor(Color.gray)
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .opacity(navbarOpacity)
      }

      Text(route?.name ?? "Route")
        .font(.headline)
        .foregroundColor(.white)
        .opacity(navbarOpacity)
        .lineLimit(1)

      Spacer()

      Button(action: {
        // Menu action
      }) {
        Image(systemName: "ellipsis")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(10)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
    .background(
      Color.newPrimaryColor.ignoresSafeArea().background(.ultraThinMaterial).opacity(navbarOpacity)
    )
    .padding(.top, safeAreaInsets.top + 30)
    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
    .animation(.easeInOut(duration: 0.3), value: navbarOpacity)
    .frame(height: 54)
  }

  var body: some View {
    ApplyBackgroundColor(
      backgroundColor: scrollOffset > imageCollapseThreshold
        ? Color.newBackgroundGray : Color.newPrimaryColor
    ) {
      DetailsViewStateMachine(details: $route, isLoading: $isLoading) {
        DetectRoutesWrapper(routes: routeList) {
          ZStack(alignment: .top) {
            ScrollView {
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
                    SectorClimbTypeView()
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

              }
              .padding(.top, imageCollapseThreshold)
              .background(
                GeometryReader { proxy -> Color in
                  DispatchQueue.main.async {
                    scrollOffset = -proxy.frame(in: .named("scroll")).origin.y
                    if startingScrollOffset == 0 {
                      startingScrollOffset = -proxy.frame(in: .named("scroll")).origin.y
                    }
                  }
                  return Color.clear
                }
              )
            }
            .safeAreaInset(edge: .top) {
              Color.clear
                .overlay(alignment: .top) {
                  navigationBarExpanded
                    .frame(height: navigationImageSize)
                    .clipped()
                }
                .frame(height: 0)
            }
            .ignoresSafeArea(edges: .top)
            .coordinateSpace(name: "scroll")

            compactNavigationBar
          }
          .ignoresSafeArea(edges: .top)
        }
      }
    }
    .fullScreenCover(isPresented: $isPresentingCreateRouteImageView) {
      CreateRouteImageView()
    }
    .task {
      await getRoute(value: routeId)
    }
    .navigationBarHidden(true)
  }
}

#Preview {
  AuthInjectionMock {
    RouteView(routeId: "ebdabd5e-3a1e-4fa5-f931-08dd3b395c5b")
  }
}
