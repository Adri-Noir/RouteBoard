// Created with <3 on 22.03.2025.

import GeneratedClient
import SwiftUI

struct GradeDistributionGraph: View {
  let routes: [SectorRouteDto]
  @Binding var selectedGrade: Components.Schemas.ClimbingGrade?
  @EnvironmentObject private var authViewModel: AuthViewModel

  private var gradeConverter: ClimbingGrades {
    authViewModel.getGradeSystem()
  }

  private var gradeDistribution: [Components.Schemas.ClimbingGrade: Int] {
    var distribution: [Components.Schemas.ClimbingGrade: Int] = [:]

    // Count routes by grade
    for route in routes {
      if let grade = route.grade {
        distribution[grade, default: 0] += 1
      }
    }

    return distribution
  }

  private var sortedGradeDistribution: [Components.Schemas.ClimbingGrade] {
    gradeConverter.sortedGrades()
  }

  // Header view extracted to reduce complexity
  private var headerView: some View {
    HStack(alignment: .center, spacing: 0) {
      Text("Grade Distribution")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      Spacer()

      if !gradeDistribution.isEmpty {
        Text("\(routes.count) routes")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor.opacity(0.7))
          .padding(.trailing, 0)
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  // Empty state view extracted
  private var emptyStateView: some View {
    Text("No grade information available")
      .font(.subheadline)
      .foregroundColor(Color.newTextColor.opacity(0.7))
      .padding(.top, 4)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  // Grade bar view for each grade
  private func gradeBarView(for grade: Components.Schemas.ClimbingGrade) -> some View {
    let count = gradeDistribution[grade] ?? 0
    let maxCount = gradeDistribution.values.max() ?? 1
    let height = CGFloat(count) / CGFloat(maxCount) * 70
    let isSelected = selectedGrade == grade

    return Button(action: {
      // Toggle selection - if already selected, deselect it
      if selectedGrade == grade {
        selectedGrade = nil
      } else {
        selectedGrade = grade
      }
    }) {
      VStack(spacing: 4) {
        Text("\(count)")
          .font(.caption)
          .foregroundColor(Color.newTextColor)

        Rectangle()
          .fill(gradeConverter.getGradeColor(grade))
          .frame(width: 24, height: height)
          .cornerRadius(4)
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
          )

        Text(gradeConverter.convertGradeToString(grade))
          .font(.caption)
          .foregroundColor(Color.newTextColor)
          .fixedSize()
      }
      .frame(minWidth: 30)
    }
  }

  // Chart view extracted
  private var chartView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .bottom, spacing: 6) {
        ForEach(
          Array(sortedGradeDistribution.filter { gradeDistribution[$0] ?? 0 > 0 }), id: \.self
        ) { grade in
          gradeBarView(for: grade)
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .animation(.easeInOut, value: routes)
      .animation(.easeInOut, value: selectedGrade)
    }
    .frame(height: 120)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      headerView

      if gradeDistribution.isEmpty {
        emptyStateView
      } else {
        chartView
      }
    }
  }
}
