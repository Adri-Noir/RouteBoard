// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct AscentTypeSelectorView: View {
  @Binding var selectedAscentType: Components.Schemas.RouteType?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Filter by Ascent Type")
        .font(.headline)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          // Add "All" button
          Button(action: {
            withAnimation {
              selectedAscentType = nil
            }
          }) {
            Text("All")
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(
                selectedAscentType == nil
                  ? Color.newPrimaryColor : Color.newBackgroundGray
              )
              .foregroundColor(selectedAscentType == nil ? .white : Color.newTextColor)
              .cornerRadius(20)
          }

          // Add other route type buttons
          ForEach(Components.Schemas.RouteType.allCases, id: \.self) { type in
            Button(action: {
              withAnimation {
                selectedAscentType = type
              }
            }) {
              Text(RouteTypeConverter.convertToString(type) ?? type.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                  selectedAscentType == type
                    ? Color.newPrimaryColor : Color.newBackgroundGray
                )
                .foregroundColor(selectedAscentType == type ? .white : Color.newTextColor)
                .cornerRadius(20)
            }
          }
        }
        .padding(.horizontal)
      }
    }
    .padding(.vertical)
    .background(Color.white)
    .cornerRadius(12)
  }
}
