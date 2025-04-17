//
//  DetailsTopView.swift
//  RouteBoard
//
//  Created with <3 on 19.01.2025..
//

import GeneratedClient
import SwiftUI

public typealias PhotoDto = Components.Schemas.PhotoDto

public struct DetailsTopView<Header: View, HeaderOverlay: View, Content: View>: View {
  let photos: [PhotoDto]
  @ViewBuilder let header: Header
  @Binding var headerVisibleRatio: CGFloat
  var headerHeight: CGFloat = 300
  @ViewBuilder let overlay: HeaderOverlay
  @ViewBuilder let content: Content

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  public init(
    photos: [PhotoDto],
    header: Header,
    headerVisibleRatio: Binding<CGFloat>,
    overlay: HeaderOverlay,
    headerHeight: CGFloat,
    @ViewBuilder content: () -> Content
  ) {
    self.photos = photos
    self.header = header
    self._headerVisibleRatio = headerVisibleRatio
    self.overlay = overlay
    self.headerHeight = headerHeight
    self.content = content()
  }

  var navigationBarExpanded: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottom) {
        TabView {
          if photos.isEmpty {
            PlaceholderImage()
              .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
              .background(Color.newBackgroundGray)
          } else {
            ForEach(photos, id: \.id) { photo in
              AsyncImage(url: URL(string: photo.url ?? "")) { phase in
                switch phase {
                case .success(let image):
                  image
                    .resizable()
                    .scaledToFill()
                case .failure:
                  PlaceholderImage()
                    .background(Color.newBackgroundGray)
                default:
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
                    .background(Color.newBackgroundGray)
                }
              }
              .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
          }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .frame(width: proxy.size.width, height: proxy.size.height)

        header
      }
    }
  }

  var compactNavigationBar: some View {
    overlay
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .padding(.vertical, 8)
      .padding(.top, safeAreaInsets.top)
      .background(
        Color.newPrimaryColor.ignoresSafeArea().background(.ultraThinMaterial).opacity(
          1 - headerVisibleRatio)
      )
      .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
      .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
  }

  public var body: some View {
    ScrollViewWithStickyHeader(
      header: {
        navigationBarExpanded
      },
      headerOverlay: {
        compactNavigationBar
      }, headerHeight: headerHeight,
      onScroll: { _, headerVisibleRatio in
        self.headerVisibleRatio = headerVisibleRatio
      }
    ) {
      content
    }
  }
}
