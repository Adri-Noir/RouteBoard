// Created with <3 on 22.03.2025.

import GeneratedClient
import SwiftUI

// MARK: - Table View for Routes
struct RoutesTableView: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  let routes: [SectorRouteDto]?
  let sectors: [SectorDetailedDto]
  let onSelectSector: (String) -> Void
  @Binding var currentPage: Int

  // Sorting state
  @State private var sortColumn: SortColumn = .name
  @State private var sortOrder: SortOrder = .ascending

  // Configuration
  private let rowsPerPage = 10
  private let tableColumnWidths: [CGFloat] = [180, 80, 80, 80, 90]

  // Sorting options
  enum SortColumn {
    case name, grade, length, type, ascents
  }

  enum SortOrder {
    case ascending, descending

    var iconName: String {
      self == .ascending ? "chevron.up" : "chevron.down"
    }

    mutating func toggle() {
      self = self == .ascending ? .descending : .ascending
    }
  }

  private var flattenedRoutesWithSectors:
    [(sectorId: String, sectorName: String, route: SectorRouteDto)]
  {
    // Use provided routes if available
    if let providedRoutes = routes {
      var result: [(sectorId: String, sectorName: String, route: SectorRouteDto)] = []

      for route in providedRoutes {
        // Find which sector this route belongs to
        for sector in sectors {
          if let sectorName = sector.name,
            let sectorRoutes = sector.routes,
            sectorRoutes.contains(where: { $0.id == route.id })
          {
            result.append((sectorId: sector.id, sectorName: sectorName, route: route))
            break
          }
        }
      }

      return sortedRoutes(result)
    }

    // Otherwise use the original logic
    var result: [(sectorId: String, sectorName: String, route: SectorRouteDto)] = []

    for sector in sectors {
      if let sectorName = sector.name, let sectorRoutes = sector.routes {
        for route in sectorRoutes {
          result.append((sectorId: sector.id, sectorName: sectorName, route: route))
        }
      }
    }

    // Apply sorting
    return sortedRoutes(result)
  }

  private func sortedRoutes(
    _ routes: [(sectorId: String, sectorName: String, route: SectorRouteDto)]
  ) -> [(sectorId: String, sectorName: String, route: SectorRouteDto)] {
    let sorted = routes.sorted { first, second in
      let shouldAscend = sortOrder == .ascending

      switch sortColumn {
      case .name:
        let firstName = first.route.name?.lowercased() ?? ""
        let secondName = second.route.name?.lowercased() ?? ""
        return shouldAscend ? firstName < secondName : firstName > secondName

      case .grade:
        guard let firstGrade = first.route.grade, let secondGrade = second.route.grade else {
          // Handle nil grades (put them at the end)
          if first.route.grade == nil && second.route.grade == nil {
            return false
          }
          return (first.route.grade == nil) != shouldAscend
        }

        let gradeConverter = authViewModel.getGradeSystem()
        let sortedGrades = gradeConverter.sortedGrades()
        let firstIndex = sortedGrades.firstIndex(of: firstGrade) ?? Int.max
        let secondIndex = sortedGrades.firstIndex(of: secondGrade) ?? Int.max
        return shouldAscend ? firstIndex < secondIndex : firstIndex > secondIndex

      case .length:
        guard let firstLength = first.route.length, let secondLength = second.route.length else {
          // Handle nil lengths (put them at the end)
          if first.route.length == nil && second.route.length == nil {
            return false
          }
          return (first.route.length == nil) != shouldAscend
        }
        return shouldAscend ? firstLength < secondLength : firstLength > secondLength

      case .type:
        let firstType = first.route.routeType?.first?.rawValue ?? ""
        let secondType = second.route.routeType?.first?.rawValue ?? ""
        return shouldAscend ? firstType < secondType : firstType > secondType

      case .ascents:
        let firstAscents = first.route.ascentsCount ?? 0
        let secondAscents = second.route.ascentsCount ?? 0
        return shouldAscend ? firstAscents < secondAscents : firstAscents > secondAscents
      }
    }

    return sorted
  }

  private var totalPages: Int {
    let totalRoutes = flattenedRoutesWithSectors.count
    return max(1, (totalRoutes + rowsPerPage - 1) / rowsPerPage)  // Ceiling division
  }

  private var currentPageData: [(sectorId: String, sectorName: String, route: SectorRouteDto)] {
    let startIndex = currentPage * rowsPerPage
    let endIndex = min(startIndex + rowsPerPage, flattenedRoutesWithSectors.count)

    if startIndex >= flattenedRoutesWithSectors.count {
      return []  // Out of bounds
    }

    return Array(flattenedRoutesWithSectors[startIndex..<endIndex])
  }

  private func sortByColumn(_ column: SortColumn) {
    if sortColumn == column {
      sortOrder.toggle()
    } else {
      sortColumn = column
      sortOrder = .ascending
    }

    // Reset to first page when sorting changes
    currentPage = 0
  }

  var body: some View {
    VStack(spacing: 10) {
      // Table content
      ScrollView(.horizontal, showsIndicators: false) {
        VStack(spacing: 0) {
          // Table header
          TableHeaderRow(
            sortColumn: $sortColumn,
            sortOrder: $sortOrder,
            columnWidths: tableColumnWidths,
            onSort: sortByColumn
          )

          // Table rows
          ForEach(Array(currentPageData.enumerated()), id: \.element.route.id) { index, item in
            RouteTableRow(
              route: item.route,
              sectorId: item.sectorId,
              sectorName: item.sectorName,
              isEven: index % 2 == 0,
              columnWidths: tableColumnWidths,
              onSelectSector: onSelectSector
            )
          }
        }
      }

      // Pagination controls
      if totalPages > 1 {
        PaginationControls(
          currentPage: $currentPage,
          totalPages: totalPages
        )
      }
    }
  }
}

// Table Header Row
struct TableHeaderRow: View {
  @Binding var sortColumn: RoutesTableView.SortColumn
  @Binding var sortOrder: RoutesTableView.SortOrder
  let columnWidths: [CGFloat]
  let onSort: (RoutesTableView.SortColumn) -> Void

  var body: some View {
    HStack(spacing: 0) {
      sortableHeaderCell(
        text: "Route Name / Sector", width: columnWidths[0], column: .name)
      sortableHeaderCell(text: "Grade", width: columnWidths[1], column: .grade)
      sortableHeaderCell(text: "Length", width: columnWidths[2], column: .length)
      sortableHeaderCell(text: "Type", width: columnWidths[3], column: .type)
      sortableHeaderCell(text: "Ascents", width: columnWidths[4], column: .ascents)
    }
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
    .padding(.horizontal, 20)
  }

  private func sortableHeaderCell(text: String, width: CGFloat, column: RoutesTableView.SortColumn)
    -> some View
  {
    Button(action: {
      onSort(column)
    }) {
      HStack {
        Text(text)
          .font(.subheadline)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        if sortColumn == column {
          Image(systemName: sortOrder.iconName)
            .font(.caption)
            .foregroundColor(Color.newPrimaryColor)
        }

        Spacer()
      }
      .frame(width: width, alignment: .leading)
      .padding(.vertical, 12)
      .padding(.horizontal, 10)
    }
  }
}

// Route Table Row
struct RouteTableRow: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  let route: SectorRouteDto
  let sectorId: String
  let sectorName: String
  let isEven: Bool
  let columnWidths: [CGFloat]
  let onSelectSector: (String) -> Void

  var body: some View {
    RouteLink(routeId: route.id) {
      HStack(spacing: 0) {
        // Name and sector
        tableDataCell(width: columnWidths[0]) {
          RouteLink(routeId: route.id) {
            VStack(alignment: .leading, spacing: 2) {
              Text(route.name ?? "Unnamed Route")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.newTextColor)
                .lineLimit(1)

              Button(action: {
                onSelectSector(sectorId)
              }) {
                Text(sectorName)
                  .font(.caption)
                  .foregroundColor(Color.newPrimaryColor)
                  .lineLimit(1)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
        }

        // Grade
        tableDataCell(width: columnWidths[1]) {
          if let grade = route.grade {
            Text(authViewModel.getGradeSystem().convertGradeToString(grade))
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(Color.newTextColor)
          } else {
            Text("-")
              .font(.subheadline)
              .foregroundColor(Color.gray)
          }
        }

        // Length
        tableDataCell(width: columnWidths[2]) {
          if let length = route.length {
            Text("\(length) m")
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
          } else {
            Text("-")
              .font(.subheadline)
              .foregroundColor(Color.gray)
          }
        }

        // Type
        tableDataCell(width: columnWidths[3]) {
          if let routeType = route.routeType?.first?.rawValue {
            Text(routeType)
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
              .lineLimit(1)
          } else {
            Text("-")
              .font(.subheadline)
              .foregroundColor(Color.gray)
          }
        }

        // Ascents
        tableDataCell(width: columnWidths[4]) {
          if let ascents = route.ascentsCount {
            Text("\(ascents)")
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
          } else {
            Text("0")
              .font(.subheadline)
              .foregroundColor(Color.gray)
          }
        }
      }
      .frame(height: 50)
      .background(isEven ? Color.white : Color.gray.opacity(0.05))
      .cornerRadius(8)
    }
  }

  private func tableDataCell<Content: View>(width: CGFloat, @ViewBuilder content: () -> Content)
    -> some View
  {
    HStack {
      content()
      Spacer()
    }
    .frame(width: width, alignment: .leading)
    .padding(.horizontal, 10)
  }
}

// Pagination Controls
struct PaginationControls: View {
  @Binding var currentPage: Int
  let totalPages: Int

  var body: some View {
    HStack(spacing: 20) {
      Button(action: {
        currentPage = max(0, currentPage - 1)
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(currentPage > 0 ? Color.newPrimaryColor : Color.gray)
      }
      .disabled(currentPage <= 0)

      Text("Page \(currentPage + 1) of \(totalPages)")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor)

      Button(action: {
        currentPage = min(totalPages - 1, currentPage + 1)
      }) {
        Image(systemName: "chevron.right")
          .foregroundColor(currentPage < totalPages - 1 ? Color.newPrimaryColor : Color.gray)
      }
      .disabled(currentPage >= totalPages - 1)
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 20)
  }
}
