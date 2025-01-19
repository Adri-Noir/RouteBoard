//
//  SectorView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import GeneratedClient
import SwiftUI

struct SectorView: View {
  let sectorId: String

  @State private var isLoading: Bool = false
  @State private var showRoutes = false
  @State private var sector: SectorDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel

  private let client = GetSectorDetailsClient()

  private var sectorRoutes: [RouteDetails] {
    sector?.routes ?? []
  }

  init(sectorId: String) {
    self.sectorId = sectorId
  }

  func getSector(value: String) async {
    isLoading = true

    guard
      let sectorDetails = await client.call(
        SectorDetailsInput(id: value), authViewModel.getAuthData())
    else {
      isLoading = false
      return
    }

    sector = sectorDetails
    isLoading = false
  }

  var body: some View {
    ApplyBackgroundColor {
      DetailsViewStateMachine(details: $sector, isLoading: $isLoading) {
        DetectRoutesWrapper(routes: sectorRoutes) {
          ScrollView {
            VStack(alignment: .leading, spacing: 25) {
              DetailsTopView(pictures: sector?.photos ?? [])

              VStack(alignment: .leading, spacing: 0) {
                Text(sector?.name ?? "Sector")
                  .font(.largeTitle)
                  .fontWeight(.semibold)
                  .foregroundStyle(.black)
                  .padding(0)

                Text(sector?.cragName ?? "")
                  .font(.title2)
                  .foregroundStyle(.gray)
                  .padding(0)
              }
              .padding(.horizontal)

              Text(sector?.description ?? "")
                .foregroundStyle(.black)
                .padding(.horizontal)

              InformationRectanglesView(sectorDetails: sector)

              Text("Current weather")
                .padding(.vertical)
                .font(.title)
                .foregroundStyle(.black)

              Button {

              } label: {
                Text("bla bla")
                  .padding()
                  .foregroundStyle(.white)
                Spacer()
              }
              .background(Color(red: 0.78, green: 0.62, blue: 0.52))
              .padding(.vertical)
              .cornerRadius(20)

              Text("Recent ascents")
                .font(.title)
                .foregroundStyle(.black)
            }
          }
        }
        .popover(isPresented: $showRoutes) {
          RoutesListView(routes: [
            SimpleRoute(id: "1", name: "Apaches", grade: "6b", numberOfAscents: 1)
          ])
        }
      }
    }
    .ignoresSafeArea(edges: .top)
    .navigationBarHidden(true)
    .task {
      await getSector(value: sectorId)
    }
  }
}

#Preview {
  AuthInjectionMock {
    SectorView(sectorId: "d9872fa7-8859-410e-9199-08dcf8780f2f")
  }
}
