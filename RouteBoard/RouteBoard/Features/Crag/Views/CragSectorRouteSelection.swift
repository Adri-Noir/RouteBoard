// Created with <3 on 10.03.2025.

import GeneratedClient
import SwiftUI

typealias SectorRouteDto = Components.Schemas.SectorRouteDto
typealias SectorDetailedDto = Components.Schemas.SectorDetailedDto

enum RouteViewMode {
  case tabs
  case list
}

// MARK: - Main View
struct CragSectorRouteSelection: View {
  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var sectorDetailsCacheClient: SectorDetailsCacheClient

  let crag: CragDetails?
  @Binding var selectedSectorId: String?
  @Binding var viewMode: RouteViewMode
  let refetch: () -> Void

  @State private var selectedSector: SectorDetailedDto?
  @State private var isLoading = true
  @State private var currentTablePage = 0
  @State private var selectedGrade: Components.Schemas.ClimbingGrade? = nil

  private var sectors: [SectorDetailedDto] {
    crag?.sectors ?? []
  }

  private var routes: [SectorRouteDto] {
    var allRoutes =
      selectedSectorId == nil
      ? sectors.flatMap { $0.routes ?? [] }
      : selectedSector?.routes ?? []

    // Apply grade filter if selected
    if let selectedGrade = selectedGrade {
      allRoutes = allRoutes.filter { $0.grade == selectedGrade }
    }

    return allRoutes
  }

  // Function to clear grade filter
  private func clearGradeFilter() {
    selectedGrade = nil
    currentTablePage = 0
  }

  var body: some View {
    VStack(spacing: 0) {
      if sectors.isEmpty || (selectedSectorId != nil && selectedSector == nil) {
        EmptySectorView()
      } else {
        // Header section
        headerSection

        // Content section
        if isLoading {
          SectorLoadingView()
            .padding(.top, 20)
        } else if routes.isEmpty {
          NoRoutesView(selectedSectorId: selectedSectorId)
            .padding(.top, 20)
        } else {
          routesContentSection
        }
      }
    }
    .task {
      loadData()
    }
    .onChange(of: selectedSectorId) { _, newId in
      handleSectorChange(newId)
    }
    .onChange(of: viewMode) { _, _ in
      // Reset pagination when view mode changes
      currentTablePage = 0
    }
  }

  // MARK: - Layout Sections

  private var headerSection: some View {
    Group {
      if selectedSectorId == nil {
        // All sectors header
        SectorHeaderView(
          title: "All Sectors",
          subtitle: "\(sectors.count) sectors with \(routes.count) routes",
          sectorPicker: sectorPicker
        )

        // Show grade distribution for all routes combined
        GradeDistributionGraph(
          routes: sectors.flatMap { $0.routes ?? [] },
          selectedGrade: $selectedGrade
        )
        .padding(.top, 8)

        // Show filter indicator if grade is selected
        if selectedGrade != nil {
          GradeFilterIndicator(
            selectedGrade: selectedGrade,
            gradeConverter: authViewModel.getGradeSystem(),
            onClear: clearGradeFilter
          )
        }
      } else if let sector = selectedSector, let sectorName = sector.name {
        // Single sector header
        SectorHeaderView(
          title: sectorName,
          subtitle: sector.description,
          sectorPicker: sectorPicker
        )

        GradeDistributionGraph(routes: sector.routes ?? [], selectedGrade: $selectedGrade)
          .padding(.top, 8)

        // Show filter indicator if grade is selected
        if selectedGrade != nil {
          GradeFilterIndicator(
            selectedGrade: selectedGrade,
            gradeConverter: authViewModel.getGradeSystem(),
            onClear: clearGradeFilter
          )
        }

        if let photos = sector.photos, !photos.isEmpty {
          GalleryView(images: photos)
            .padding(.top, 8)
            .padding(.horizontal, ThemeExtension.horizontalPadding)
        }
      }
    }
  }

  private var routesContentSection: some View {
    Group {
      if selectedSectorId == nil {
        // All sectors view
        if viewMode == .tabs {
          AllSectorsRoutesView(
            sectors: sectors,
            viewMode: viewMode,
            selectedGrade: selectedGrade,
            onSectorSelect: { sectorId in
              withAnimation {
                selectedSectorId = sectorId
              }
            }
          )
        } else {
          RoutesTableView(
            routes: routes,
            sectors: sectors,
            onSelectSector: { sectorId in
              selectedSectorId = sectorId
            },
            currentPage: $currentTablePage
          )
          .padding(.top, 10)
        }
      } else {
        // Single sector view
        switch viewMode {
        case .tabs:
          RouteTabView(routes: routes)
        case .list:
          RoutesTableView(
            routes: routes,
            sectors: [selectedSector].compactMap { $0 },
            onSelectSector: { _ in },
            currentPage: $currentTablePage
          )
          .padding(.top, 10)
        }
      }
    }
  }

  // MARK: - Picker

  private var sectorPicker: some View {
    SectorPickerView(
      sectors: sectors,
      selectedSector: selectedSector,
      selectedSectorId: $selectedSectorId,
      refetch: refetch
    )
  }

  // MARK: - Data Loading

  private func loadData() {
    isLoading = true

    // Load selected sector if any
    if let sectorId = selectedSectorId {
      loadSector(id: sectorId)
    } else {
      isLoading = false
    }
  }

  private func loadSector(id: String) {
    if let sector = sectors.first(where: { $0.id == id }) {
      selectedSector = sector
      isLoading = false
    } else {
      isLoading = false
    }
  }

  private func handleSectorChange(_ newId: String?) {
    if let newId = newId {
      loadSector(id: newId)
    } else {
      // Reset selected sector when "All" is selected
      selectedSector = nil
      isLoading = false
    }
  }
}

struct GradeFilterIndicator: View {
  let selectedGrade: Components.Schemas.ClimbingGrade?
  let gradeConverter: ClimbingGrades
  let onClear: () -> Void

  var body: some View {
    HStack {
      if let grade = selectedGrade {
        HStack {
          Text("Filtered by grade: ")
            .font(.subheadline)
            .foregroundColor(Color.newTextColor)

          Text(gradeConverter.convertGradeToString(grade))
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              Capsule()
                .fill(gradeConverter.getGradeColor(grade))
            )
        }

        Spacer()

        Button(action: onClear) {
          HStack(spacing: 4) {
            Image(systemName: "xmark.circle.fill")
              .font(.caption)

            Text("Clear filter")
              .font(.caption)
          }
          .foregroundColor(Color.newPrimaryColor)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.newPrimaryColor, lineWidth: 1)
          )
        }
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.top, 4)
    .padding(.bottom, 8)
  }
}
