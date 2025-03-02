// Created with <3 on 01.03.2025.

import SwiftUI

public struct ScrollViewHeader<Content: View>: View {

  public init(
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.content = content
  }

  private let content: () -> Content

  public var body: some View {
    GeometryReader { geo in
      content().stretchable(in: geo)
    }
  }
}

extension View {

  @ViewBuilder
  fileprivate func stretchable(in geo: GeometryProxy) -> some View {
    let width = geo.size.width
    let height = geo.size.height
    let minY = geo.frame(in: .global).minY
    let useStandard = minY <= 0

    self
      .frame(width: width, height: height + (useStandard ? 0 : minY))
      .offset(y: useStandard ? 0 : -minY)
  }
}

enum ScrollOffsetNamespace {

  static let namespace = "scrollView"
}

struct ScrollOffsetPreferenceKey: PreferenceKey {

  static var defaultValue: CGPoint = .zero

  static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViewOffsetTracker: View {

  var body: some View {
    GeometryReader { geo in
      Color.clear
        .preference(
          key: ScrollOffsetPreferenceKey.self,
          value:
            geo
            .frame(in: .named(ScrollOffsetNamespace.namespace))
            .origin
        )
    }
    .frame(height: 0)
  }
}

extension ScrollView {

  fileprivate func withOffsetTracking(
    action: @escaping (_ offset: CGPoint) -> Void
  ) -> some View {
    self.coordinateSpace(name: ScrollOffsetNamespace.namespace)
      .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
  }
}

public struct ScrollViewWithOffset<Content: View>: View {

  public init(
    _ axes: Axis.Set = .vertical,
    showsIndicators: Bool = true,
    onScroll: ScrollAction? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.onScroll = onScroll ?? { _ in }
    self.content = content
  }

  private let axes: Axis.Set
  private let showsIndicators: Bool
  private let onScroll: ScrollAction
  private let content: () -> Content

  public typealias ScrollAction = (_ offset: CGPoint) -> Void

  public var body: some View {
    ScrollView(axes, showsIndicators: showsIndicators) {
      ZStack(alignment: .top) {
        ScrollViewOffsetTracker()
        content()
      }
    }.withOffsetTracking(action: onScroll)
  }
}

public struct ScrollViewWithStickyHeader<Header: View, HeaderOverlay: View, Content: View>: View {

  public init(
    _ axes: Axis.Set = .vertical,
    @ViewBuilder header: @escaping () -> Header,
    @ViewBuilder headerOverlay: @escaping () -> HeaderOverlay,
    headerHeight: CGFloat,
    showsIndicators: Bool = true,
    onScroll: ScrollAction? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.header = header
    self.headerHeight = headerHeight
    self.onScroll = onScroll
    self.content = content
    self.headerOverlay = headerOverlay
  }

  private let axes: Axis.Set
  private let showsIndicators: Bool
  private let header: () -> Header
  private let headerOverlay: () -> HeaderOverlay
  private let headerHeight: CGFloat
  private let onScroll: ScrollAction?
  private let content: () -> Content

  public typealias ScrollAction = (_ offset: CGPoint, _ headerVisibleRatio: CGFloat) -> Void

  @State
  private var navigationBarHeight: CGFloat = 0

  @State
  private var scrollOffset: CGPoint = .zero

  private var headerVisibleRatio: CGFloat {
    max(0, (headerHeight + scrollOffset.y) / headerHeight)
  }

  public var body: some View {
    ZStack(alignment: .top) {
      scrollView
      navbarOverlay
    }
    .prefersNavigationBarHidden()
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }
}

extension ScrollViewWithStickyHeader {
  @ViewBuilder
  fileprivate var navbarOverlay: some View {
    headerOverlay()
      .ignoresSafeArea(edges: .top)
  }

  fileprivate var scrollView: some View {
    GeometryReader { proxy in
      ScrollViewWithOffset(onScroll: handleScrollOffset) {
        VStack(spacing: 0) {
          scrollHeader
          content()
        }
      }
      .onAppear {
        DispatchQueue.main.async {
          navigationBarHeight = proxy.safeAreaInsets.top
        }
      }
    }
  }

  fileprivate var scrollHeader: some View {
    ScrollViewHeader(content: header)
      .frame(height: headerHeight)
  }

  fileprivate func handleScrollOffset(_ offset: CGPoint) {
    self.scrollOffset = offset
    self.onScroll?(offset, headerVisibleRatio)
  }
}

extension View {

  @ViewBuilder
  fileprivate func prefersNavigationBarHidden() -> some View {
    #if os(iOS) || os(macOS)
      if #available(iOS 16.0, macOS 13.0, *) {
        self.toolbarBackground(.hidden)
      } else {
        self
      }
    #else
      self
    #endif
  }
}

#Preview {
  ScrollViewWithStickyHeader(
    header: {
      GeometryReader { proxy in
        ZStack(alignment: .bottom) {
          VStack {
            Image("TestingSamples/limski/pikachu")
              .resizable()
              .scaledToFill()
              .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
          }

          HStack(spacing: 0) {
            Spacer()

            Button(action: {
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
      }
    },
    headerOverlay: {
      Color.clear
        .background(Color.red)
        .frame(height: 100)
    }, headerHeight: 300
  ) {
    VStack {
      ForEach(0..<100) { index in
        Text("Content \(index)")
      }
    }
    .frame(maxWidth: .infinity)
    .background(Color.newPrimaryColor)
  }
}
