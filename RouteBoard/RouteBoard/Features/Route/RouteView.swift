//
//  RouteView.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import GeneratedClient
import SwiftUI

// MARK: - Loading View Component
struct RouteLoadingView: View {
  var body: some View {
    ZStack {
      Color.black.opacity(0.8)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .scaleEffect(1.5)

        Text("Loading route details...")
          .font(.headline)
          .foregroundColor(.white)
      }
    }
  }
}

// MARK: - Exit Fullscreen Button Component
struct ExitFullscreenButton: View {
  let onExit: () -> Void

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: onExit) {
          Image(systemName: "xmark")
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .semibold))
            .padding(12)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
        }
        .padding(.top, 60)
        .padding(.trailing, 20)
      }
      Spacer()
    }
  }
}

// MARK: - Main Route View
struct RouteView: View {
  let routeId: String

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  @State private var hasAppeared = false
  @State private var route: RouteDetails?

  @State private var isLoading: Bool = false
  @State private var errorMessage: String? = nil
  @State private var isPresentingCreateRouteImageView = false
  @State private var isPresentingRouteARView = false
  @State private var isPresentingRouteAscentsView = false
  @State private var isPresentingRouteLogAscent = false
  @State private var showMenu = false
  @State private var isFullscreenMode = false

  private let getRouteDetailsClient = GetRouteDetailsClient()

  init(routeId: String) {
    self.routeId = routeId
  }

  func getRoute(value: String) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let routeDetails = await getRouteDetailsClient.call(
        RouteDetailsInput(id: value), authViewModel.getAuthData(), { errorMessage = $0 })
    else {
      return
    }

    self.route = routeDetails
  }

  var userAscent: Components.Schemas.AscentDto? {
    return route?.ascents?.first(where: { ascent in
      ascent.userId == authViewModel.user?.id
    })
  }

  var userHasAscended: Bool {
    return userAscent != nil
  }

  var userAscentDate: Date? {
    guard let userAscent = userAscent else {
      return nil
    }

    guard let dateString = userAscent.ascentDate else {
      return nil
    }

    return DateTimeConverter.convertDateStringToDate(dateString: dateString)
  }

  var climbingTypes: [UserClimbingType] {
    if let route = route, let categories = route.routeCategories {
      return ClimbTypesConverter.convertComponentsClimbTypesToUserClimbingTypes(
        componentsClimbTypes: categories.climbTypes ?? []
      )
        + ClimbTypesConverter.convertComponentsRockTypesToUserClimbingTypes(
          componentsRockTypes: categories.rockTypes ?? []
        )
        + ClimbTypesConverter.convertComponentsHoldTypesToUserClimbingTypes(
          componentsHoldTypes: categories.holdTypes ?? []
        )
    }
    return []
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      // Show loading state when data is loading
      if isLoading && route == nil {
        RouteLoadingView()
      } else {
        // Background image with gradient overlay
        RouteBackgroundView(
          route: route,
          isFullscreenMode: isFullscreenMode,
          onTap: {
            withAnimation(.easeInOut(duration: 0.3)) {
              isFullscreenMode.toggle()
            }
          }
        )

        // Bottom information section
        VStack(spacing: 0) {
          Spacer()
          HStack {
            RouteInfoView(route: route, climbingTypes: climbingTypes)
            Spacer()
          }
          .padding(.horizontal, 24)

          if !isFullscreenMode {
            RouteAscentButton(
              userHasAscended: userHasAscended,
              userAscentDate: userAscentDate,
              onLogAscent: { isPresentingRouteLogAscent = true }
            )
            .padding(.bottom, 20)
            .padding(.top, 10)
          }
        }
        .opacity(isFullscreenMode ? 0 : 1)

        // Top navigation bar
        VStack {
          RouteNavigationBar(
            route: route,
            onDismiss: { dismiss() },
            onAscentsView: { isPresentingRouteAscentsView = true },
            onCreateRouteImage: { isPresentingCreateRouteImageView = true },
            onRouteARView: { isPresentingRouteARView = true }
          )
          Spacer()
        }
        .opacity(isFullscreenMode ? 0 : 1)

        // Exit fullscreen button
        if isFullscreenMode {
          ExitFullscreenButton(
            onExit: {
              withAnimation(.easeInOut(duration: 0.3)) {
                isFullscreenMode = false
              }
            }
          )
        }
      }
    }
    .ignoresSafeArea()
    .fullScreenCover(isPresented: $isPresentingCreateRouteImageView) {
      CreateRouteImageView(routeId: routeId)
    }
    .sheet(isPresented: $isPresentingRouteAscentsView) {
      AllAscentsView(route: route)
    }
    .fullScreenCover(isPresented: $isPresentingRouteARView) {
      RouteFinderView(routeId: routeId)
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
    .onAppearOnce {
      Task {
        await getRoute(value: routeId)
      }
    }
    .navigationBarHidden(true)
    .alert(
      message: $errorMessage,
      primaryAction: {
        dismiss()
      })
  }
}

#Preview {
  AuthInjectionMock {
    RouteView(routeId: "33501545-18d2-4491-2110-08dd60e356b0")
  }
}
