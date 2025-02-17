//
//  CragTopContainerView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

struct CragTopContainerView<Content: View>: View {
  let crag: CragDetails?
  @ViewBuilder var content: Content

  @Environment(\.dismiss) private var dismiss

  init(crag: CragDetails?, @ViewBuilder content: @escaping () -> Content) {
    self.crag = crag
    self.content = content()
  }

  var body: some View {
    content
      .navigationBarBackButtonHidden()
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(crag?.name ?? "Crag")
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
