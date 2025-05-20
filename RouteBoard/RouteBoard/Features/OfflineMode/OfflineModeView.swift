// Created with <3 on 18.05.2025.

import SwiftData
import SwiftUI

struct OfflineModeView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedTab: Tab = .crags
  @State private var headerVisibleRatio: CGFloat = 1

  private enum Tab: String, CaseIterable {
    case crags = "Crags"
    case routes = "Routes"
  }

  private var safeAreaInsets: UIEdgeInsets {
    #if os(iOS)
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first
      else { return .zero }
      return window.safeAreaInsets
    #else
      return .zero
    #endif
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      VStack(spacing: 0) {
        // Static Header
        HStack(alignment: .center) {
          Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
              .foregroundColor(.newPrimaryColor)
          }
          Text("Offline Mode")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.newPrimaryColor)
          Spacer()
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .padding(.top, 20)
        .padding(.bottom, 8)

        // Custom Tab Bar
        HStack(spacing: 0) {
          ForEach(Tab.allCases, id: \.self) { tab in
            Button(action: { withAnimation { selectedTab = tab } }) {
              VStack(spacing: 4) {
                Text(tab.rawValue)
                  .font(.headline)
                  .fontWeight(selectedTab == tab ? .bold : .regular)
                  .foregroundColor(selectedTab == tab ? .newPrimaryColor : .gray)
                Rectangle()
                  .frame(height: 3)
                  .foregroundColor(selectedTab == tab ? .newPrimaryColor : .clear)
              }
              .frame(maxWidth: .infinity)
            }
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .padding(.bottom, 8)

        switch selectedTab {
        case .crags:
          OfflineCragTabView()
        case .routes:
          OfflineRoutesTabView()
        }
      }
      .background(Color.newBackgroundGray)
    }
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
  Navigator { manager in
    OfflineModeView()
  }
}
