//
//  RouteTopInfoContainerView.swift
//  RouteBoard
//
//  Created with <3 on 25.01.2025..
//

import GeneratedClient
import SwiftUI

struct RouteTopInfoContainerView: View {
  let route: RouteDetails?

  @EnvironmentObject var authModel: AuthViewModel

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      VStack(alignment: .center) {
        Text(String(authModel.getGradeSystem().convertGradeToString(route?.grade)))
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Grade")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
      }

      Spacer()

      VStack(alignment: .center) {
        Text(String(route?.length ?? 0) + "m")
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Length")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .frame(width: 50)
      }

      Spacer()

      VStack(alignment: .center) {
        Text("7")
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Ascents")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .frame(width: 50)
      }
    }
    .padding(.horizontal, 40)
  }
}
