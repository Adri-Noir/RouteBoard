//
//  RouteView.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import GeneratedClient
import SwiftUI

struct RouteView: View {
  let routeId: String

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  @State private var route: RouteDetails?
  @State private var routeSamples: [DetectSample] = []

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

  func getRoute(value: String, shouldDownloadSamples: Bool = true) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let routeDetails = await getRouteDetailsClient.call(
        RouteDetailsInput(id: value), authViewModel.getAuthData(), { errorMessage = $0 })
    else {
      return
    }

    self.route = routeDetails
    if shouldDownloadSamples {
      routeSamples = await PhotoDownloader.downloadPhoto(
        routePhotos: routeDetails.routePhotos ?? [])
    }
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
    if let route = route {
      return route.ascents?.flatMap { ascent in
        ClimbTypesConverter.convertComponentsClimbTypesToUserClimbingTypes(
          componentsClimbTypes: ascent.climbTypes ?? []
        )
          + ClimbTypesConverter.convertComponentsRockTypesToUserClimbingTypes(
            componentsRockTypes: ascent.rockTypes ?? []
          )
          + ClimbTypesConverter.convertComponentsHoldTypesToUserClimbingTypes(
            componentsHoldTypes: ascent.holdTypes ?? []
          )
      } ?? []
    }
    return []
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      // Show loading state when data is loading
      if isLoading && route == nil {
        loadingView
      } else {
        // Background image with gradient overlay
        routeBackgroundView
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
              isFullscreenMode.toggle()
            }
          }

        // Bottom information section
        VStack(spacing: 0) {
          Spacer()
          HStack {
            routeInfoView
            Spacer()
          }
          .padding(.horizontal, 24)

          if !isFullscreenMode {
            logAscentButton
              .padding(.bottom, 20)
              .padding(.top, 10)
          }
        }
        .opacity(isFullscreenMode ? 0 : 1)

        // Top navigation bar
        VStack {
          topNavigationBar
          Spacer()
        }
        .opacity(isFullscreenMode ? 0 : 1)

        // Exit fullscreen button
        if isFullscreenMode {
          VStack {
            HStack {
              Spacer()
              Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                  isFullscreenMode = false
                }
              }) {
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
    }
    .ignoresSafeArea()
    .fullScreenCover(isPresented: $isPresentingCreateRouteImageView) {
      CreateRouteImageView()
    }
    .sheet(isPresented: $isPresentingRouteAscentsView) {
      AllAscentsView(route: route)
    }
    .fullScreenCover(isPresented: $isPresentingRouteARView) {
      RouteFinderView(routeSamples: routeSamples)
    }
    .sheet(isPresented: $isPresentingRouteLogAscent) {
      RouteLogAscent(
        route: route,
        onAscentLogged: {
          Task {
            await getRoute(value: routeId, shouldDownloadSamples: false)
          }
        })
    }
    .task {
      await getRoute(value: routeId)
    }
    .onDisappear {
      getRouteDetailsClient.cancelRequest()
    }
    .navigationBarHidden(true)
    .alert(
      message: $errorMessage,
      primaryAction: {
        dismiss()
      })
  }

  // Loading view
  private var loadingView: some View {
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

  // Background image with gradient overlay
  private var routeBackgroundView: some View {
    GeometryReader { geometry in
      ZStack {
        // Route image
        if let route = route, let firstPhoto = route.routePhotos?.first?.image?.url,
          !firstPhoto.isEmpty
        {
          AsyncImage(url: URL(string: firstPhoto)) { phase in
            switch phase {
            case .empty:
              Color.gray
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
              Image("TestingSamples/limski/pikachu")
                .resizable()
                .aspectRatio(contentMode: .fill)
            @unknown default:
              Image("TestingSamples/limski/pikachu")
                .resizable()
                .aspectRatio(contentMode: .fill)
            }
          }
          .frame(width: geometry.size.width, height: geometry.size.height)
        } else {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

        // Gradient overlay
        LinearGradient(
          gradient: Gradient(colors: [
            Color.black.opacity(isFullscreenMode ? 0 : 1),
            Color.black.opacity(isFullscreenMode ? 0 : 0.75),
            Color.black.opacity(isFullscreenMode ? 0 : 0.5),
            Color.black.opacity(0),
          ]),
          startPoint: .bottom,
          endPoint: .top
        )
        .animation(.easeInOut(duration: 0.3), value: isFullscreenMode)
      }
    }
  }

  // Top navigation bar with buttons
  private var topNavigationBar: some View {
    HStack {
      // Back button
      Button(action: {
        dismiss()
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(12)
          .background(Color.black.opacity(0.6))
          .clipShape(Circle())
      }

      Spacer()

      // Ascents count button
      Button(action: {
        isPresentingRouteAscentsView = true
      }) {
        HStack(spacing: 6) {
          Image(systemName: "figure.climbing")
            .foregroundColor(.white)

          Text("\(route?.ascents?.count ?? 0)")
            .foregroundColor(.white)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
      }

      // Menu button
      Menu {
        Button(action: {
          isPresentingCreateRouteImageView = true
        }) {
          Label("Add Route Image", systemImage: "camera")
        }

        if !routeSamples.isEmpty {
          Button(action: {
            isPresentingRouteARView = true
          }) {
            Label("Route AR", systemImage: "arkit")
          }
        }
      } label: {
        Image(systemName: "ellipsis")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(16)
          .background(Color.black.opacity(0.6))
          .clipShape(Circle())
      }
    }
    .padding(.horizontal, 20)
    .padding(.top, 60)  // Account for safe area
  }

  // Bottom information section
  private var routeInfoView: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Route name
      Text(route?.name ?? "Unknown Route")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.white)

      // Location info
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 6) {
          Image(systemName: "mappin.circle.fill")
            .foregroundColor(.white.opacity(0.8))

          CragLink(cragId: route?.cragId ?? "") {
            Text(route?.cragName ?? "Unknown Crag")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))
          }
        }

        HStack(spacing: 6) {
          Image(systemName: "square.grid.2x2.fill")
            .foregroundColor(.white.opacity(0.8))

          SectorLink(sectorId: route?.sectorId) {
            Text(route?.sectorName ?? "Unknown Sector")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))
          }
        }

        if let route = route, let grade = route.grade {
          HStack(spacing: 6) {
            Image(systemName: "chart.bar.fill")
              .foregroundColor(.white.opacity(0.8))

            Text("Grade: ")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))

            Text(authViewModel.getGradeSystem().convertGradeToString(grade))
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(.white)
          }
        }

        if let route = route, let routeTypes = route.routeType, !routeTypes.isEmpty {
          HStack(spacing: 6) {
            Image(systemName: "figure.climbing")
              .foregroundColor(.white.opacity(0.8))

            Text("Type: ")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))

            Text(
              routeTypes.compactMap { RouteTypeConverter.convertToString($0) }.joined(
                separator: ", ")
            )
            .font(.headline)
            .foregroundColor(.white)
          }
        }

        if !climbingTypes.isEmpty {
          VStack(alignment: .leading, spacing: 4) {
            Text("Climbing Characteristics:")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(
                  Array(Set(climbingTypes)).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self
                ) { type in
                  Text(type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.newPrimaryColor.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }
              .padding(.vertical, 4)
            }
          }
          .padding(.top, 4)
        }

        if let route = route, let description = route.description, !description.isEmpty {
          VStack(alignment: .leading, spacing: 4) {
            Text("Description:")
              .font(.headline)
              .foregroundColor(.white.opacity(0.9))

            Text(description)
              .font(.body)
              .foregroundColor(.white.opacity(0.9))
              .lineLimit(3)
          }
          .padding(.top, 4)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, 10)  // Reduced bottom padding since button is now below
    .padding(.top, 20)
  }

  // Log ascent button
  private var logAscentButton: some View {
    HStack {
      Spacer()

      if userHasAscended {
        Text(
          "Ascended on: \(userAscentDate?.formatted(date: .long, time: .omitted) ?? "Unknown")"
        )
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 20))
      } else {
        Button(action: {
          isPresentingRouteLogAscent = true
        }) {
          HStack(spacing: 8) {
            Image(systemName: "plus")
              .foregroundColor(.white)
              .font(.system(size: 18, weight: .semibold))

            Text("Log Ascent")
              .foregroundColor(.white)
              .font(.system(size: 16, weight: .semibold))
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 16)
          .background(Color.black.opacity(0.75))
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
      }

      Spacer()
    }
  }
}

#Preview {
  AuthInjectionMock {
    RouteView(routeId: "33501545-18d2-4491-2110-08dd60e356b0")
  }
}
