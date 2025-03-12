// Created with <3 on 10.03.2025.

import GeneratedClient
import SwiftUI

typealias CragSectorDto = Components.Schemas.CragSectorDto
typealias SectorRouteDto = Components.Schemas.SectorRouteDto
typealias SectorDetailedDto = Components.Schemas.SectorDetailedDto

enum RouteViewMode {
  case tabs
  case list
}

struct CragSectorRouteSelection: View {
  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var sectorDetailsCacheClient: SectorDetailsCacheClient

  let crag: CragDetails?
  @Binding var selectedSectorId: String?

  @State private var selectedSector: SectorDetails?
  @State private var viewMode: RouteViewMode = .tabs
  @State private var isSectorSelectorOpen = false
  @State private var isLoading = true

  private var sectors: [CragSectorDto] {
    crag?.sectors ?? []
  }

  private var routes: [SectorRouteDto] {
    selectedSector?.routes ?? []
  }

  func getSector(id: String) async {
    isLoading = true
    defer { isLoading = false }

    let sector = await sectorDetailsCacheClient.call(
      SectorDetailsInput(id: id), authViewModel.getAuthData(), nil)
    selectedSector = sector
  }

  var body: some View {
    VStack(spacing: 0) {
      if sectors.isEmpty || selectedSector == nil {
        emptyStateView
      } else {
        if let sector = selectedSector, let sectorName = sector.name {
          sectorHeaderWithViewSwitcher(name: sectorName, description: sector.description)

          GradeDistributionGraph(routes: routes)
            .padding(.top, 8)

          if let photos = sector.photos, !photos.isEmpty {
            GalleryView(images: photos)
              .padding(.top, 8)
              .padding(.horizontal, 20)
          }
        }

        if isLoading {
          loadingView
            .padding(.top, 20)
        } else if routes.isEmpty {
          noRoutesView
            .padding(.top, 20)
        } else {
          switch viewMode {
          case .tabs:
            routesTabView
          case .list:
            routesListView
          }
        }
      }
    }
    .task {
      if let sectorId = selectedSectorId {
        await getSector(id: sectorId)
      }
    }
    .onChange(of: selectedSectorId) { _, newValue in
      if let sectorId = newValue {
        Task {
          await getSector(id: sectorId)
        }
      }
    }
  }

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)
        .padding(.bottom, 8)

      Text("Loading sector data...")
        .font(.headline)
        .foregroundColor(Color.newTextColor)
    }
    .frame(maxWidth: .infinity, minHeight: 200)
    .padding()
  }

  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "mountain.2")
        .font(.system(size: 60))
        .foregroundColor(Color.newTextColor)

      Text("No sectors available")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      Text("This crag doesn't have any sectors yet.")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    .frame(maxWidth: .infinity, minHeight: 200)
    .padding()
  }

  private var sectorPicker: some View {
    Group {
      if sectors.count <= 1 {
        Text(selectedSector?.name ?? "Select Sector")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)
      } else {
        Button {
          isSectorSelectorOpen.toggle()
        } label: {
          HStack(spacing: 4) {
            Text(selectedSector?.name ?? "Select Sector")
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(Color.newTextColor)

            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(Color.newTextColor)
          }
          .foregroundColor(Color.newTextColor)
        }
        .popover(
          isPresented: $isSectorSelectorOpen,
          attachmentAnchor: .point(.bottom),
          arrowEdge: .top
        ) {
          ScrollView {
            VStack(alignment: .leading, spacing: 8) {
              ForEach(sectors, id: \.id) { sector in
                Button(action: {
                  withAnimation {
                    selectedSectorId = sector.id
                  }
                  isSectorSelectorOpen = false
                }) {
                  HStack {
                    Text(sector.name ?? "Unnamed Sector")
                    Spacer()
                    if selectedSectorId == sector.id {
                      Image(systemName: "checkmark")
                    }
                  }
                  .padding(.vertical, 6)
                  .padding(.horizontal, 12)
                  .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Color.newTextColor)

                if sector.id != sectors.last?.id {
                  Divider()
                }
              }
            }
            .padding(.vertical, 12)
            .frame(width: 200)
          }
          .preferredColorScheme(.light)
          .presentationCompactAdaptation(.popover)
        }
      }
    }
  }

  private func sectorHeaderWithViewSwitcher(name: String, description: String?) -> some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        sectorPicker
        if let description = description, !description.isEmpty {
          Text(description)
            .font(.subheadline)
            .foregroundColor(Color.newTextColor)
            .multilineTextAlignment(.leading)
        }
      }

      Spacer()

      ViewModeSwitcher(viewMode: $viewMode)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
  }

  private var routesTabView: some View {
    TabView {
      ForEach(routes, id: \.id) { route in
        RouteCardFullscreen(route: route)
      }
    }
    .tabViewStyle(PageTabViewStyle())
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .frame(height: 500)
    .animation(.easeInOut, value: selectedSectorId)
    .transition(.opacity)
  }

  private var routesListView: some View {
    LazyVStack(spacing: 16) {
      ForEach(routes, id: \.id) { route in
        RouteCardList(route: route)
      }
    }
    .padding(.vertical, 10)
  }

  private var noRoutesView: some View {
    VStack(spacing: 12) {
      Image(systemName: "figure.climbing")
        .font(.system(size: 40))
        .foregroundColor(Color.newTextColor)

      Text("No routes available")
        .font(.headline)
        .foregroundColor(Color.newTextColor)
      Text("This sector doesn't have any routes yet.")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .cornerRadius(12)
    .padding(.horizontal, 20)
  }
}

struct RouteCardList: View {
  let route: SectorRouteDto
  private let gradeConverter = FrenchClimbingGrades()

  var body: some View {
    RouteLink(routeId: route.id) {
      HStack(spacing: 12) {
        // Route thumbnail
        if let photos = route.routePhotos, !photos.isEmpty, let imageUrl = photos.first?.image?.url,
          let url = URL(string: imageUrl)
        {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.2))
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              PlaceholderImage()
            @unknown default:
              EmptyView()
            }
          }
          .frame(width: 100, height: 150)
          .cornerRadius(8)
          .clipped()
        } else {
          PlaceholderImage()
            .frame(width: 100, height: 150)
            .cornerRadius(8)
        }

        // Route info
        VStack(alignment: .leading, spacing: 4) {
          Text(route.name ?? "Unnamed Route")
            .font(.headline)
            .foregroundColor(Color.newTextColor)
            .lineLimit(1)

          if let routeType = route.routeType {
            RouteInfoItem(icon: "arrow.up", label: routeType.first?.rawValue ?? "Unknown")
          }

          RouteInfoItem(
            icon: "ruler", label: route.length != nil ? "\(route.length!) m" : "Unknown")

          if let ascentsCount = route.ascentsCount {
            RouteInfoItem(
              icon: "checkmark.circle",
              label: "\(ascentsCount) ascent\(ascentsCount == 1 ? "" : "s")"
            )
          }
        }

        Spacer()

        // Grade
        if let grade = route.grade {
          GradeTag(grade: grade, gradeConverter: gradeConverter)
        }
      }
      .padding()
      .background(Color.white)
      .cornerRadius(12)
      .padding(.horizontal, 20)
    }
  }
}

struct RouteCardFullscreen: View {
  let route: SectorRouteDto
  private let gradeConverter = FrenchClimbingGrades()

  var body: some View {
    RouteLink(routeId: route.id) {
      ZStack(alignment: .bottom) {
        // Background image
        if let photos = route.routePhotos, !photos.isEmpty, let imageUrl = photos.first?.image?.url,
          let url = URL(string: imageUrl)
        {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.2))
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              PlaceholderImage()
            @unknown default:
              EmptyView()
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
        } else {
          PlaceholderImage()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }

        // Gradient overlay
        LinearGradient(
          gradient: Gradient(
            colors: [
              Color.black.opacity(0.0),
              Color.black.opacity(0.5),
              Color.black.opacity(0.8),
            ]
          ),
          startPoint: .top,
          endPoint: .bottom
        )

        // Route info
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(route.name ?? "Unnamed Route")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

              if let description = route.description, !description.isEmpty {
                Text(description)
                  .font(.subheadline)
                  .foregroundColor(.white.opacity(0.8))
                  .lineLimit(2)
              }
            }

            Spacer()

            if let grade = route.grade {
              GradeTagLarge(grade: grade, gradeConverter: gradeConverter)
            }
          }

          HStack(spacing: 20) {
            RouteInfoItemLight(
              icon: "ruler", label: route.length != nil ? "\(route.length!) m" : "Unknown")

            if let routeType = route.routeType {
              RouteInfoItemLight(icon: "arrow.up", label: routeType.first?.rawValue ?? "Unknown")
            }

            if let ascentsCount = route.ascentsCount {
              RouteInfoItemLight(
                icon: "checkmark.circle",
                label: "\(ascentsCount) ascent\(ascentsCount == 1 ? "" : "s")"
              )
            }

            Spacer()

            if let photos = route.routePhotos, photos.count > 1 {
              RouteInfoItemLight(icon: "photo.on.rectangle", label: "\(photos.count) photos")
            }
          }

          // Photo indicators if multiple photos
          if let photos = route.routePhotos, photos.count > 1 {
            HStack(spacing: 4) {
              ForEach(0..<min(photos.count, 5), id: \.self) { _ in
                Circle()
                  .fill(Color.white.opacity(0.6))
                  .frame(width: 6, height: 6)
              }

              if photos.count > 5 {
                Text("+\(photos.count - 5)")
                  .font(.caption2)
                  .foregroundColor(.white.opacity(0.6))
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
      }
      .cornerRadius(16)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }
  }
}

struct GradeTagLarge: View {
  let grade: Components.Schemas.ClimbingGrade
  let gradeConverter: FrenchClimbingGrades

  var body: some View {
    Text(gradeConverter.convertGradeToString(grade))
      .font(.system(.title3, design: .rounded))
      .fontWeight(.bold)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(gradeColor(for: gradeConverter.convertGradeToString(grade)))
      )
      .foregroundColor(.white)
  }

  private func gradeColor(for gradeString: String) -> Color {
    // Simple color mapping based on grade difficulty
    if gradeString.contains("3") || gradeString.contains("4") {
      return .green
    } else if gradeString.contains("5") || gradeString.contains("6a") || gradeString.contains("6b")
    {
      return .blue
    } else if gradeString.contains("6c") || gradeString.contains("7a") || gradeString.contains("7b")
    {
      return .orange
    } else if gradeString.contains("7c") || gradeString.contains("8") || gradeString.contains("9") {
      return .red
    } else {
      return .gray
    }
  }
}

struct RouteInfoItemLight: View {
  let icon: String
  let label: String

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.subheadline)
        .foregroundColor(.white)

      Text(label)
        .font(.subheadline)
        .foregroundColor(.white)
    }
  }
}

struct GradeTag: View {
  let grade: Components.Schemas.ClimbingGrade
  let gradeConverter: FrenchClimbingGrades

  var body: some View {
    Text(gradeConverter.convertGradeToString(grade))
      .font(.system(.subheadline, design: .rounded))
      .fontWeight(.bold)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(
        Capsule()
          .fill(gradeColor(for: gradeConverter.convertGradeToString(grade)))
      )
      .foregroundColor(.white)
  }

  private func gradeColor(for gradeString: String) -> Color {
    // Simple color mapping based on grade difficulty
    if gradeString.contains("3") || gradeString.contains("4") {
      return .green
    } else if gradeString.contains("5") || gradeString.contains("6a") || gradeString.contains("6b")
    {
      return .blue
    } else if gradeString.contains("6c") || gradeString.contains("7a") || gradeString.contains("7b")
    {
      return .orange
    } else if gradeString.contains("7c") || gradeString.contains("8") || gradeString.contains("9") {
      return .red
    } else {
      return .gray
    }
  }
}

struct RouteInfoItem: View {
  let icon: String
  let label: String

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.footnote)
        .foregroundColor(Color.newTextColor)

      Text(label)
        .font(.footnote)
        .foregroundColor(Color.newTextColor)
    }
  }
}

struct ViewModeSwitcher: View {
  @Binding var viewMode: RouteViewMode
  @State private var isViewSelectorOpen = false

  var body: some View {
    Button {
      isViewSelectorOpen.toggle()
    } label: {
      Image(systemName: viewMode == .tabs ? "rectangle.grid.1x2" : "list.bullet")
        .font(.title3)
        .foregroundColor(Color.newTextColor)
        .frame(width: 44, height: 44)
        .cornerRadius(8)
    }
    .popover(
      isPresented: $isViewSelectorOpen,
      attachmentAnchor: .point(.bottom),
      arrowEdge: .top
    ) {
      VStack(alignment: .leading, spacing: 8) {
        Button(action: {
          withAnimation {
            viewMode = .tabs
          }
          isViewSelectorOpen = false
        }) {
          HStack {
            Label("Tab View", systemImage: "rectangle.grid.1x2")
              .foregroundColor(Color.newTextColor)
            Spacer()
            if viewMode == .tabs {
              Image(systemName: "checkmark")
                .foregroundColor(Color.newTextColor)
            }
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 12)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())

        Divider()

        Button(action: {
          withAnimation {
            viewMode = .list
          }
          isViewSelectorOpen = false
        }) {
          HStack {
            Label("List View", systemImage: "list.bullet")
              .foregroundColor(Color.newTextColor)
            Spacer()
            if viewMode == .list {
              Image(systemName: "checkmark")
                .foregroundColor(Color.newTextColor)
            }
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 12)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
      }
      .padding(.vertical, 12)
      .frame(width: 200)
      .preferredColorScheme(.light)
      .presentationCompactAdaptation(.popover)
    }
  }
}

struct GradeDistributionGraph: View {
  let routes: [SectorRouteDto]
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
    .padding(.horizontal, 20)
  }

  // Empty state view extracted
  private var emptyStateView: some View {
    Text("No grade information available")
      .font(.subheadline)
      .foregroundColor(Color.newTextColor.opacity(0.7))
      .padding(.top, 4)
  }

  // Grade bar view for each grade
  private func gradeBarView(for grade: Components.Schemas.ClimbingGrade) -> some View {
    let count = gradeDistribution[grade] ?? 0
    let maxCount = gradeDistribution.values.max() ?? 1
    let height = CGFloat(count) / CGFloat(maxCount) * 70

    return VStack(spacing: 4) {
      Text("\(count)")
        .font(.caption)
        .foregroundColor(Color.newTextColor)

      Rectangle()
        .fill(gradeConverter.getGradeColor(grade))
        .frame(width: 24, height: height)
        .cornerRadius(4)

      Text(gradeConverter.convertGradeToString(grade))
        .font(.caption)
        .foregroundColor(Color.newTextColor)
        .fixedSize()
    }
    .frame(minWidth: 30)
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
      .padding(.horizontal, 20)
      .animation(.easeInOut, value: routes)
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
