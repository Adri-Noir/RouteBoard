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
    try? await Task.sleep(nanoseconds: 1_000_000_000)

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
            VStack(alignment: .leading, spacing: 0) {
              ImageCarouselView(imagesNames: sector?.photos ?? [], height: 500)
                .cornerRadius(20)

              Text(sector?.name ?? "Sector")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding()

              Text(sector?.description ?? "")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.black)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 10))

              // make hstack which will contain two boxes, one with ascents and another with number of likes
              // make a button which will open a popover with routes
              // make a button which will like the sector

              InformationRectanglesView(
                handleOpenRoutesView: {
                  showRoutes = true
                },
                handleLike: {
                  print("liked sector")
                },
                ascentsGraph: {
                  Text("Ascents")
                },
                gradesGraphModel: GradesGraphModel(grades: [
                  GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3),
                  GradeCount(grade: "6a", count: 1),
                ]))

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
            .padding()
          }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(sector?.name ?? "Sector")
        .popover(isPresented: $showRoutes) {
          RoutesListView(routes: [
            SimpleRoute(id: "1", name: "Apaches", grade: "6b", numberOfAscents: 1)
          ])
        }
      }
    }
    .task {
      await getSector(value: sectorId)
    }
  }
}

#Preview {
  AuthInjectionMock {
    SectorView(sectorId: "4260561a-0967-40fd-fb7b-08dd29344a74")
  }
}
