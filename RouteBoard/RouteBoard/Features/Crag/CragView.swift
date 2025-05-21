//
//  CragView.swift
//  RouteBoard
//
//  Created with <3 on 01.01.2025..
//

import GeneratedClient
import SwiftData
import SwiftUI

struct CragView: View {
  var cragId: String? = nil
  var sectorId: String? = nil
  var isOffline: Bool = false

  @Query private var crags: [DownloadedCrag]
  private var downloadedCrag: DownloadedCrag? { crags.first(where: { $0.id == cragId }) }

  @State private var selectedSectorId: String? = nil
  @State private var isLoading: Bool = false
  @State private var crag: CragDetails?
  @State private var errorMessage: String? = nil
  @State private var viewMode: RouteViewMode = .tabs

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  private let cragDetailsClient = GetCragDetailsClient()
  private let sectorCragDetailsClient = GetSectorCragDetailsClient()

  init(cragId: String) {
    self.cragId = cragId
  }

  init(sectorId: String) {
    self.sectorId = sectorId
  }

  init(cragId: String, isOffline: Bool) {
    self.cragId = cragId
    self.isOffline = isOffline
  }

  func getCrag(value: String) async {
    isLoading = true
    defer { isLoading = false }

    self.selectedSectorId = nil

    guard
      let cragDetails = await cragDetailsClient.call(
        CragDetailsInput(id: value), authViewModel.getAuthData(), { errorMessage = $0 })
    else {
      return
    }

    self.crag = cragDetails
  }

  func getCragFromSectorId(value: String) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let cragDetails = await sectorCragDetailsClient.call(
        SectorCragDetailsInput(id: value), authViewModel.getAuthData(),
        { errorMessage = $0 })
    else {
      return
    }

    self.crag = cragDetails
    self.selectedSectorId = value
  }

  var routesCount: Int {
    crag?.sectors?.reduce(
      0,
      { (sum: Int, sector: SectorDetailedDto) in
        sum + (sector.routes?.count ?? 0)
      }) ?? 0
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      DetailsViewStateMachine(details: $crag, isLoading: $isLoading) {
        CragHeaderView(crag: crag) {
          VStack(spacing: 0) {
            VStack(spacing: 20) {
              VStack(spacing: 8) {
                Text(crag?.name ?? "")
                  .font(.largeTitle)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 40)

                HStack {
                  Spacer()

                  HStack {
                    Text("\(crag?.sectors?.count ?? 0) Sectors")
                      .font(.subheadline)
                      .foregroundColor(Color.white)

                    Text("•")
                      .font(.subheadline)
                      .foregroundColor(Color.white)
                      .padding(.horizontal, 4)

                    Text("\(routesCount) Routes")
                      .font(.subheadline)
                      .foregroundColor(Color.white)
                  }

                  Spacer()
                }
              }

              if !isOffline {
                CragTopInfoContainerView(crag: crag)
              }

              CragMapView(crag: crag, selectedSectorId: $selectedSectorId)
            }
            .padding(.horizontal, ThemeExtension.horizontalPadding)
            .padding(.vertical, 20)
            .background(Color.newPrimaryColor)

            VStack(spacing: 20) {
              HStack {
                Spacer()

                Text("Sectors")
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(Color.newTextColor)

                SectorViewModeSwitcher(viewMode: $viewMode)

                Spacer()
              }

              CragSectorRouteSelection(
                crag: crag,
                selectedSectorId: $selectedSectorId,
                viewMode: $viewMode,
                refetch: {
                  Task {
                    if let cragId = crag?.id {
                      await getCrag(value: cragId)
                    }
                  }
                }
              )

              Spacer()
            }
            .padding(.top, 20)
            .background(Color.newBackgroundGray)
            .clipShape(
              .rect(
                topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                topTrailingRadius: 40)
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
            .mask(
              Rectangle().padding(.top, -40)
            )
            .background(Color.newPrimaryColor)
          }
        }
      }
    }
    .navigationBarHidden(true)
    .task {
      Task {
        if isOffline == true, let downloadedCrag = downloadedCrag {
          crag = CragDetails(
            id: downloadedCrag.id,
            name: downloadedCrag.name,
            description: downloadedCrag.descriptionText,
            locationName: downloadedCrag.locationName,
            sectors: downloadedCrag.sectors.map { sector in
              SectorDetailedDto(
                id: sector.id ?? "",
                name: sector.name,
                location: sector.location,
                routes: sector.routes.map { route in
                  SectorRouteDto(
                    id: route.id ?? "",
                    name: route.name,
                    description: route.descriptionText,
                    grade: route.grade,
                    createdAt: String(describing: route.createdAt),
                    routeType: route.routeType,
                    length: route.length.map(Int32.init),
                    routeCategories: nil,
                    routePhotos: nil,
                    ascentsCount: nil
                  )
                }
              )
            }
          )

          return
        }

        if let cragId = cragId {
          await getCrag(value: cragId)
        } else if let sectorId = sectorId {
          await getCragFromSectorId(value: sectorId)
        }
      }
    }
    .alert(
      message: $errorMessage,
      primaryAction: {
        dismiss()
      })
  }
}

#Preview {
  Navigator { _ in
    APIClientInjection {
      AuthInjectionMock {
        CragView(cragId: "01963122-3e11-78d2-ab9f-62d939d6b02b")
      }
    }
  }
}
