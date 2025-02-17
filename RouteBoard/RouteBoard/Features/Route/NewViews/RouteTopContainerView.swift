//
//  RouteTopContainerView.swift
//  RouteBoard
//
//  Created with <3 on 25.01.2025..
//

import GeneratedClient
import SwiftUI

struct RouteTopContainerView<Content: View>: View {
  let route: RouteDetails?
  @ViewBuilder var content: Content

  @Environment(\.dismiss) private var dismiss
  @State private var isPresentingCreateRouteImageView = false

  init(route: RouteDetails?, @ViewBuilder content: @escaping () -> Content) {
    self.route = route
    self.content = content()
  }

  var body: some View {
    content
      .navigationBarBackButtonHidden()
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(route?.name ?? "Route")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "arrow.left")
              .font(.title2)
              .foregroundColor(.white)
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button("Download Locally", action: { print("option 1") })
            Button("Add Route Image", action: { isPresentingCreateRouteImageView = true })
            Button("Option 3", action: { print("option 3") })
          } label: {
            Image(systemName: "ellipsis")
              .font(.title2)
              .foregroundColor(.white)
          }
        }
      }
      .toolbarBackground(Color.newPrimaryColor)
      .fullScreenCover(isPresented: $isPresentingCreateRouteImageView) {
        CreateRouteImageView()
      }
  }
}
