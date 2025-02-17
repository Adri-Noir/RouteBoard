//
//  SectorTopContainerView.swift
//  RouteBoard
//
//  Created with <3 on 24.01.2025..
//

import GeneratedClient
import SwiftUI

struct SectorTopContainerView<Content: View>: View {
  let sector: SectorDetails?
  @ViewBuilder var content: Content

  @Environment(\.dismiss) private var dismiss

  init(sector: SectorDetails?, @ViewBuilder content: @escaping () -> Content) {
    self.sector = sector
    self.content = content()
  }

  var body: some View {
    content
      .navigationBarBackButtonHidden()
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(sector?.name ?? "Sector")
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
            Button("Option 2", action: { print("option 2") })
            Button("Option 3", action: { print("option 3") })
          } label: {
            Image(systemName: "ellipsis")
              .font(.title2)
              .foregroundColor(.white)
          }
        }
      }
  }
}
