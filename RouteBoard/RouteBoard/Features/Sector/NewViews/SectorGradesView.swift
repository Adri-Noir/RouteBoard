//
//  SectorGradesView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 24.01.2025..
//

import GeneratedClient
import SwiftUI

struct SectorGradesView: View {
  let sector: SectorDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    VStack {
      HStack {
        Text("Grades")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Spacer()
      }
      .padding(.horizontal, 20)

      GradesGraphView(
        gradesModel: GradesGraphModel(
          sector: sector, gradeStandard: authViewModel.getGradeSystem())
      )
      .frame(height: 200)
    }
  }
}
