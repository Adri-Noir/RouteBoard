// Created with <3 on 31.05.2025.

import GeneratedClient
import SwiftUI

private struct UserAscentRowView: View {
  let ascent: Components.Schemas.UserAscentDto
  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var navigationManager: NavigationManager

  var climbTypes: some View {
    HStack(alignment: .top, spacing: 10) {
      VStack(alignment: .leading, spacing: 5) {
        // Climb types
        if let climbTypes = ascent.climbTypes, !climbTypes.isEmpty {
          HStack {
            Image(systemName: "figure.climbing")
              .foregroundColor(Color.newPrimaryColor)
          }
        }

        // Rock types
        if let rockTypes = ascent.rockTypes, !rockTypes.isEmpty {
          HStack {
            Image(systemName: "mountain.2")
              .foregroundColor(Color.newPrimaryColor)
          }
        }

        // Hold types
        if let holdTypes = ascent.holdTypes, !holdTypes.isEmpty {
          HStack {
            Image(systemName: "hand.raised")
              .foregroundColor(Color.newPrimaryColor)
          }
        }
      }

      VStack(alignment: .leading, spacing: 5) {
        if let climbTypes = ascent.climbTypes, !climbTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(climbTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
        }

        if let rockTypes = ascent.rockTypes, !rockTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(rockTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
        }

        if let holdTypes = ascent.holdTypes, !holdTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(holdTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
        }

        if ascent.climbTypes?.isEmpty == true, ascent.rockTypes?.isEmpty == true,
          ascent.holdTypes?.isEmpty == true
        {
          Text("No tags")
            .font(.caption)
            .foregroundColor(Color.gray)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  var body: some View {
    VStack(spacing: 0) {
      // Route information header
      HStack(spacing: 15) {
        VStack(alignment: .leading, spacing: 3) {
          Button(action: {
            navigationManager.pushView(.routeDetails(id: ascent.routeId ?? ""))
          }) {
            Text(ascent.routeName ?? "Unknown Route")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newPrimaryColor)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .buttonStyle(PlainButtonStyle())

          HStack {
            Text(ascent.cragName ?? "Unknown Crag")
              .font(.caption)
              .foregroundColor(Color.gray)

            if let sectorName = ascent.sectorName {
              Text("• \(sectorName)")
                .font(.caption)
                .foregroundColor(Color.gray)
            }
          }
        }

        Spacer()

        if let ascentType = ascent.ascentType {
          Text(ascentType.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ascentTypeColor(ascentType))
            .cornerRadius(8)
        }
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)

      Divider()
        .padding(.horizontal, 15)

      // Climb details
      HStack(alignment: .center, spacing: 15) {
        // Grade
        VStack(alignment: .center, spacing: 3) {
          Text("Grade")
            .font(.caption)
            .foregroundColor(Color.gray)

          Text(authViewModel.getGradeSystem().convertGradeToString(ascent.proposedGrade))
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color.newPrimaryColor)
        }
        .frame(width: 70)

        Divider()
          .frame(height: 50)

        climbTypes
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)

      // Notes section if available
      if let notes = ascent.notes, !notes.isEmpty {
        Divider()
          .padding(.horizontal, 15)

        HStack(alignment: .center) {
          Image(systemName: "text.quote")
            .foregroundColor(Color.newPrimaryColor)
            .padding(.top, 2)

          Text(notes)
            .font(.caption)
            .foregroundColor(Color.newTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
      }

      // Rating if available
      if let rating = ascent.rating, rating > 0 {
        Divider()
          .padding(.horizontal, 15)

        HStack {
          Text("Rating:")
            .font(.caption)
            .foregroundColor(Color.gray)

          HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
              Image(systemName: star <= rating ? "star.fill" : "star")
                .foregroundColor(star <= rating ? .yellow : .gray)
                .font(.caption)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
      }

      // Number of attempts if available
      if let attempts = ascent.numberOfAttempts, attempts > 0 {
        HStack {
          Text("Attempts: \(attempts)")
            .font(.caption)
            .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
      }
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.vertical, 5)
  }

  // Helper function to determine color based on ascent type
  private func ascentTypeColor(_ ascentType: Components.Schemas.AscentType) -> Color {
    switch ascentType {
    case .Onsight:
      return Color.green
    case .Flash:
      return Color.blue
    case .Redpoint:
      return Color.orange
    case .Aid:
      return Color.purple
    }
  }
}

struct GroupedAscents: Equatable {
  let date: String
  let formattedDate: String
  let ascents: [Components.Schemas.UserAscentDto]

  static func == (lhs: GroupedAscents, rhs: GroupedAscents) -> Bool {
    return lhs.date == rhs.date && lhs.formattedDate == rhs.formattedDate
      && lhs.ascents.count == rhs.ascents.count
      && lhs.ascents.elementsEqual(rhs.ascents) { $0.id == $1.id }
  }
}

struct AllUserAscentsView: View {
  let userId: String

  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  @State private var ascents: [Components.Schemas.UserAscentDto] = []
  @State private var groupedAscents: [GroupedAscents] = []
  @State private var isLoading = false
  @State private var currentPage = 0
  @State private var totalCount = 0
  @State private var errorMessage: String? = nil

  private let pageSize = 5
  private let getAllUserAscentsClient = GetAllUserAscentsClient()

  private var totalPages: Int {
    max(1, (totalCount + pageSize - 1) / pageSize)
  }

  private var hasNextPage: Bool {
    currentPage < totalPages - 1
  }

  private var hasPreviousPage: Bool {
    currentPage > 0
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Section Header
      Text("Ascents History")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if totalCount > 0 {
        Text("\(totalCount) total ascents")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor.opacity(0.7))
      }

      // Content Area
      VStack(spacing: 0) {
        if isLoading && ascents.isEmpty {
          loadingStateView
        } else if groupedAscents.isEmpty {
          emptyStateView
        } else {
          ascentsContentView
        }

        // Pagination Controls (integrated into the white container)
        if !groupedAscents.isEmpty || isLoading {
          paginationControlsView
        }
      }
      .background(Color.white.opacity(0.9))
      .cornerRadius(8)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .alert(message: $errorMessage)
    .onAppear {
      if ascents.isEmpty {
        Task {
          await loadAscents(page: 0)
        }
      }
    }
  }

  // MARK: - Sub Views

  @ViewBuilder
  private var loadingStateView: some View {
    VStack(spacing: 12) {
      ForEach(0..<3, id: \.self) { _ in
        VStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 16)

          RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
            .frame(height: 80)
        }
      }
    }
    .padding()
    .frame(minHeight: 200)
  }

  @ViewBuilder
  private var emptyStateView: some View {
    VStack(spacing: 12) {
      Image(systemName: "figure.climbing")
        .font(.system(size: 40))
        .foregroundColor(Color.newTextColor.opacity(0.5))

      Text("No ascents recorded yet")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor.opacity(0.7))

      Text("Start climbing and log your first ascent!")
        .font(.caption)
        .foregroundColor(Color.newTextColor.opacity(0.5))
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding()
    .frame(minHeight: 200)
  }

  @ViewBuilder
  private var ascentsContentView: some View {
    LazyVStack(spacing: 12) {
      ForEach(Array(groupedAscents.enumerated()), id: \.element.date) { index, group in
        VStack(spacing: 0) {
          // Add divider before each group except the first one
          if index > 0 {
            Divider()
              .padding(.vertical, 8)
          }

          ascentGroupView(group: group)
        }
      }
    }
  }

  @ViewBuilder
  private func ascentGroupView(group: GroupedAscents) -> some View {
    VStack(spacing: 8) {
      // Date header
      HStack {
        Spacer()

        Text(group.formattedDate)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)

        Spacer()
      }
      .padding(.top, group == groupedAscents.first ? 0 : 12)

      // Ascents for this date
      ForEach(group.ascents, id: \.id) { ascent in
        CompactUserAscentRowView(ascent: ascent)
      }
    }
  }

  @ViewBuilder
  private var paginationControlsView: some View {
    if totalPages > 1 {
      VStack(spacing: 8) {
        Divider()
          .padding(.vertical, 8)

        // Page controls
        HStack {
          // Previous button
          Button(action: {
            Task {
              await loadAscents(page: currentPage - 1)
            }
          }) {
            HStack(spacing: 4) {
              Image(systemName: "chevron.left")
                .font(.caption2)
              Text("Previous")
                .font(.caption)
            }
            .foregroundColor(hasPreviousPage ? Color.newPrimaryColor : Color.gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .fill(
                  hasPreviousPage ? Color.newPrimaryColor.opacity(0.1) : Color.gray.opacity(0.1))
            )
          }
          .disabled(!hasPreviousPage || isLoading)

          Spacer()

          // Page indicator
          Text("Page \(currentPage + 1) of \(totalPages)")
            .font(.caption)
            .foregroundColor(Color.newTextColor.opacity(0.7))

          Spacer()

          // Next button
          Button(action: {
            Task {
              await loadAscents(page: currentPage + 1)
            }
          }) {
            HStack(spacing: 4) {
              Text("Next")
                .font(.caption)
              Image(systemName: "chevron.right")
                .font(.caption2)
            }
            .foregroundColor(hasNextPage ? Color.newPrimaryColor : Color.gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .fill(hasNextPage ? Color.newPrimaryColor.opacity(0.1) : Color.gray.opacity(0.1))
            )
          }
          .disabled(!hasNextPage || isLoading)
        }
        .padding(.vertical, 8)
      }
    }
  }

  // MARK: - Helper Methods

  private func loadAscents(page: Int) async {
    isLoading = true

    defer {
      isLoading = false
    }

    let input = GetAllUserAscentsInput(
      profileUserId: userId,
      page: page,
      pageSize: pageSize
    )

    guard
      let response = await getAllUserAscentsClient.call(
        input,
        authViewModel.getAuthData(),
        { errorMessage = $0 }
      )
    else {
      return
    }

    let newAscents = response.ascents ?? []
    totalCount = Int(response.totalCount ?? 0)

    // Replace current ascents with new page data
    ascents = newAscents
    currentPage = page

    // Group ascents by date
    groupAscents()
  }

  private func groupAscents() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .medium  // Shorter format for compact display

    var groups: [String: [Components.Schemas.UserAscentDto]] = [:]

    for ascent in ascents {
      guard let ascentDateString = ascent.ascentDate else { continue }

      // Use DateTimeConverter utility function
      guard let date = DateTimeConverter.convertDateStringToDate(dateString: ascentDateString)
      else { continue }

      let dateKey = dateFormatter.string(from: date)

      if groups[dateKey] == nil {
        groups[dateKey] = []
      }
      groups[dateKey]?.append(ascent)
    }

    // Convert to GroupedAscents and sort
    groupedAscents = groups.compactMap { (dateKey, ascents) in
      guard let date = dateFormatter.date(from: dateKey) else { return nil }

      let formattedDate = displayFormatter.string(from: date)
      let sortedAscents = ascents.sorted { first, second in
        // Sort by ascent date within the same day (newest first)
        guard let firstDate = first.ascentDate,
          let secondDate = second.ascentDate,
          let firstParsed = DateTimeConverter.convertDateStringToDate(dateString: firstDate),
          let secondParsed = DateTimeConverter.convertDateStringToDate(dateString: secondDate)
        else {
          return false
        }
        return firstParsed > secondParsed
      }

      return GroupedAscents(
        date: dateKey,
        formattedDate: formattedDate,
        ascents: sortedAscents
      )
    }.sorted { first, second in
      // Sort groups by date (newest first)
      guard let firstDate = dateFormatter.date(from: first.date),
        let secondDate = dateFormatter.date(from: second.date)
      else {
        return false
      }
      return firstDate > secondDate
    }
  }
}

// MARK: - Compact Ascent Row View

private struct CompactUserAscentRowView: View {
  let ascent: Components.Schemas.UserAscentDto
  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var navigationManager: NavigationManager

  var body: some View {
    VStack(spacing: 6) {
      // Route info header
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(ascent.routeName ?? "Unknown Route")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Color.newTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)

          HStack {
            Text(ascent.cragName ?? "Unknown Crag")
              .font(.caption)
              .foregroundColor(Color.newTextColor.opacity(0.7))

            if let sectorName = ascent.sectorName {
              Text("• \(sectorName)")
                .font(.caption)
                .foregroundColor(Color.newTextColor.opacity(0.7))
            }
          }
        }

        Spacer()

        // Grade and ascent type
        HStack(spacing: 8) {
          Text(authViewModel.getGradeSystem().convertGradeToString(ascent.proposedGrade))
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Color.newPrimaryColor)

          if let ascentType = ascent.ascentType {
            Text(ascentType.rawValue)
              .font(.caption2)
              .fontWeight(.medium)
              .foregroundColor(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(ascentTypeColor(ascentType))
              .cornerRadius(4)
          }
        }
      }

      // Additional info and View Route button
      HStack {
        // Additional info (notes, rating, attempts) - only if present
        if hasAdditionalInfo {
          VStack(alignment: .leading, spacing: 4) {
            if let notes = ascent.notes, !notes.isEmpty {
              HStack {
                Image(systemName: "text.quote")
                  .font(.caption2)
                  .foregroundColor(Color.newTextColor.opacity(0.5))

                Text(notes)
                  .font(.caption)
                  .foregroundColor(Color.newTextColor.opacity(0.7))
                  .lineLimit(2)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }

            HStack {
              if let rating = ascent.rating, rating > 0 {
                HStack(spacing: 1) {
                  ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                      .foregroundColor(star <= rating ? .yellow : .gray)
                      .font(.caption2)
                  }
                }
              }

              if let attempts = ascent.numberOfAttempts, attempts > 0 {
                Text("\(attempts) attempts")
                  .font(.caption)
                  .foregroundColor(Color.newTextColor.opacity(0.6))
              }
            }
          }
        }

        Spacer()

        // View Route button
        Button(action: {
          navigationManager.pushView(.routeDetails(id: ascent.routeId ?? ""))
        }) {
          Text("View Route")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color.newPrimaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .fill(Color.newPrimaryColor.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .padding(.vertical, 8)
    .background(Color.white.opacity(0.7))
    .cornerRadius(6)
  }

  private var hasAdditionalInfo: Bool {
    (ascent.notes?.isEmpty == false) || (ascent.rating != nil && ascent.rating! > 0)
      || (ascent.numberOfAttempts != nil && ascent.numberOfAttempts! > 0)
  }

  private func ascentTypeColor(_ ascentType: Components.Schemas.AscentType) -> Color {
    switch ascentType {
    case .Onsight:
      return Color.green
    case .Flash:
      return Color.blue
    case .Redpoint:
      return Color.orange
    case .Aid:
      return Color.purple
    }
  }
}
