// Created with <3 on 04.04.2025.

import SwiftUI

struct SectorViewModeSwitcher: View {
  @Binding var viewMode: RouteViewMode
  @State private var isViewSelectorOpen = false

  var body: some View {
    Button {
      isViewSelectorOpen.toggle()
    } label: {
      Image(systemName: viewMode == .tabs ? "rectangle.grid.1x2" : "list.bullet")
        .font(.title3)
        .foregroundColor(Color.newTextColor)
        .frame(width: 44, height: 44)
        .cornerRadius(8)
    }
    .popover(
      isPresented: $isViewSelectorOpen,
      attachmentAnchor: .point(.bottom),
      arrowEdge: .top
    ) {
      VStack(alignment: .leading, spacing: 8) {
        Button(action: {
          withAnimation {
            viewMode = .tabs
          }
          isViewSelectorOpen = false
        }) {
          HStack {
            Label("Tab View", systemImage: "rectangle.grid.1x2")
              .foregroundColor(Color.newTextColor)
            Spacer()
            if viewMode == .tabs {
              Image(systemName: "checkmark")
                .foregroundColor(Color.newTextColor)
            }
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 12)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())

        Divider()

        Button(action: {
          withAnimation {
            viewMode = .list
          }
          isViewSelectorOpen = false
        }) {
          HStack {
            Label("List View", systemImage: "list.bullet")
              .foregroundColor(Color.newTextColor)
            Spacer()
            if viewMode == .list {
              Image(systemName: "checkmark")
                .foregroundColor(Color.newTextColor)
            }
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 12)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
      }
      .padding(.vertical, 12)
      .frame(width: 200)
      .preferredColorScheme(.light)
      .presentationCompactAdaptation(.popover)
    }
  }
}
