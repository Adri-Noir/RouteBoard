//
//  CragView.swift
//  RouteBoard
//
//  Created with <3 on 01.01.2025..
//

import GeneratedClient
import SwiftUI

struct CragView: View {
  let cragId: String
  var sectorId: String? = nil

  @State private var selectedSectorId: String? = nil
  @State private var isLoading: Bool = false
  @State private var crag: CragDetails?
  @State private var errorMessage: String? = nil

  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var cragDetailsCacheClient: CragDetailsCacheClient
  @Environment(\.dismiss) private var dismiss

  init(cragId: String) {
    self.cragId = cragId
  }

  func getCrag(value: String) async {
    isLoading = true
    defer { isLoading = false }

    guard
      let cragDetails = await cragDetailsCacheClient.call(
        CragDetailsInput(id: value), authViewModel.getAuthData(), { errorMessage = $0 })
    else {
      return
    }

    self.crag = cragDetails
    self.selectedSectorId = cragDetails.sectors?.first?.id
  }

  var routesCount: Int32 {
    crag?.sectors?.reduce(
      0,
      { (sum: Int32, sector: CragSectorDto) in
        sum + (sector.routesCount ?? 0)
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
              Text("Sectors")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.newTextColor)

              if let sectors = crag?.sectors, !sectors.isEmpty {
                CragSectorRouteSelection(crag: crag, selectedSectorId: $selectedSectorId)
              }

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
    .navigationBarBackButtonHidden()
    .task {
      if let sectorId = sectorId {
        selectedSectorId = sectorId
      }
      await getCrag(value: cragId)
    }
    .onDisappear {
      cragDetailsCacheClient.cancel()
    }
    .alert(
      message: $errorMessage,
      primaryAction: {
        dismiss()
      })
  }
}

#Preview {
  APIClientInjection {
    AuthInjectionMock {
      CragView(cragId: "7a1da5fe-a1f3-4d80-7115-08dd60e35697")
    }
  }
}
