//
//  CragView.swift
//  RouteBoard
//
//  Created with <3 on 01.01.2025..
//

import GeneratedClient
import SwiftUI

struct CragView: View {
  var cragId: String? = nil
  var sectorId: String? = nil

  @State private var hasAppeared = false
  @State private var selectedSectorId: String? = nil
  @State private var isLoading: Bool = false
  @State private var crag: CragDetails?
  @State private var errorMessage: String? = nil
  @State private var viewMode: RouteViewMode = .tabs

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let cragDetailsClient = GetCragDetailsClient()
  private let sectorCragDetailsClient = GetSectorCragDetailsClient()

  init(cragId: String) {
    self.cragId = cragId
  }

  init(sectorId: String) {
    self.sectorId = sectorId
  }

  func getCrag(value: String) async {
    isLoading = true
    defer { isLoading = false }

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

              CragTopInfoContainerView(crag: crag)

              CragMapView(crag: crag, selectedSectorId: $selectedSectorId)
            }
            .padding(.horizontal, 20)
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
                crag: crag, selectedSectorId: $selectedSectorId, viewMode: $viewMode)

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
        CragView(cragId: "0195fd82-69d0-73ab-9b92-04a2bc14caa2")
      }
    }
  }
}
