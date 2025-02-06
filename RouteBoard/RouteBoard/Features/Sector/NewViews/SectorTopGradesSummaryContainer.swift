//
//  TopGradesSummaryContainer.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 24.01.2025..
//

import GeneratedClient
import SwiftUI

struct SectorTopGradesSummaryContainer: View {
  let sector: SectorDetails?

  @State var medianGrade: String = "?"
  @State var medianLength: String = "?"

  @EnvironmentObject var authViewModel: AuthViewModel

  init(sector: SectorDetails?) {
    self.sector = sector
  }

  func calculateSectorInfo() {
    let gradesModel = GradesGraphModel(
      sector: sector, gradeStandard: authViewModel.getGradeSystem())
    self.medianGrade = gradesModel.medianGrade

    if let routes = sector?.routes, !routes.isEmpty {
      let lengths = routes.compactMap { $0.length }
      let sortedLengths = lengths.sorted()
      if sortedLengths.isEmpty {
        self.medianLength = "?"
      } else {
        let middle = sortedLengths.count / 2
        if sortedLengths.count % 2 == 0 {
          self.medianLength = "\((sortedLengths[middle-1] + sortedLengths[middle])/2)m"
        } else {
          self.medianLength = "\(sortedLengths[middle])m"
        }
      }
    }
  }

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      VStack(alignment: .center) {
        Text(String(sector?.routes?.count ?? 0))
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Routes")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
      }

      Spacer()

      VStack(alignment: .center) {
        Text(medianLength)
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Median Length")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .frame(width: 50)
      }

      Spacer()

      VStack(alignment: .center) {
        Text(medianGrade)
          .font(.title)
          .fontWeight(.semibold)
          .foregroundColor(.white)

        Text("Median Grade")
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .frame(width: 50)
      }
    }
    .padding(.horizontal, 40)
    .task {
      calculateSectorInfo()
    }
  }
}
