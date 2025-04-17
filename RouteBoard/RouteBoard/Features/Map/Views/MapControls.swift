// Created with <3 on 16.03.2025.

import MapKit
import SwiftUI

public struct MapControls: View {
  var mapScope: Namespace.ID
  var isLoading: Bool
  var dismiss: DismissAction

  public var body: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "arrow.left")
            .font(.title2)
            .foregroundColor(Color.white)
            .padding(12)
            .background(Color.black.opacity(0.8))
            .clipShape(Circle())
            .shadow(radius: 2)
        }

        Spacer()

        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.2)
            .padding(10)
            .background(Color.black.opacity(0.7))
            .clipShape(Circle())
            .shadow(radius: 2)
        }
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)

      Spacer()

      HStack {
        Spacer()

        MapCompass(scope: mapScope)
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
  }
}
