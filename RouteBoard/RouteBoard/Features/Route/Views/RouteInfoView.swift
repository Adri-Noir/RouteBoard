// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteInfoView: View {
  let route: RouteDetails?
  let climbingTypes: [UserClimbingType]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Route name
      Text(route?.name ?? "Unknown Route")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.white)

      // Location info
      RouteLocationSection(route: route)

      // Characteristics
      RouteCharacteristicsView(climbingTypes: climbingTypes)

      // Description
      RouteDescriptionView(route: route)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, 10)  // Reduced bottom padding since button is now below
    .padding(.top, 20)
  }
}
