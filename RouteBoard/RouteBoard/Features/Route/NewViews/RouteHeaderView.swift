// Created with <3 on 01.03.2025.

import GeneratedClient
import SwiftUI

struct RouteHeaderView<Content: View>: View {
  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  let route: RouteDetails?
  let content: Content
  @Binding var isPresentingRouteLogAscent: Bool

  @State private var headerVisibleRatio: CGFloat = 1

  init(
    route: RouteDetails?, isPresentingRouteLogAscent: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) {
    self.route = route
    self.content = content()
    self._isPresentingRouteLogAscent = isPresentingRouteLogAscent
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

  var routePhotos: [String] {
    route?.routePhotos?.map {
      $0.image?.url ?? ""
    }
    .filter {
      $0 != ""
    } ?? []
  }

  var navigationBarExpanded: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottom) {
        AsyncImage(url: URL(string: routePhotos.first ?? "")) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        } placeholder: {
          Image("TestingSamples/limski/pikachu")
            .resizable()
            .scaledToFill()
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }

        HStack(spacing: 0) {
          Spacer()

          if userHasAscended {
            Text(
              "Ascended on: \(userAscentDate?.formatted(date: .long, time: .omitted) ?? "Unknown")"
            )
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
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
              .padding(.vertical, 10)
              .padding(.trailing, 16)
              .padding(.leading, 10)
              .background(Color.black.opacity(0.75))
              .clipShape(RoundedRectangle(cornerRadius: 20))
            }
          }
        }
        .padding(20)
      }
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

      Group {
        AsyncImage(url: URL(string: routePhotos.first ?? "")) { image in
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

        Text(route?.name ?? "Route")
          .font(.headline)
          .foregroundColor(.white)
          .lineLimit(1)
      }
      .opacity(1 - headerVisibleRatio)

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
    .padding(.top, safeAreaInsets.top)
    .background(
      Color.newPrimaryColor.ignoresSafeArea().background(.ultraThinMaterial).opacity(
        1 - headerVisibleRatio)
    )
    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
    .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)

  }

  var body: some View {
    ScrollViewWithStickyHeader(
      header: {
        navigationBarExpanded
      },
      headerOverlay: {
        compactNavigationBar
      }, headerHeight: 300,
      onScroll: { _, headerVisibleRatio in
        self.headerVisibleRatio = headerVisibleRatio
      }
    ) {
      content
    }
  }
}
