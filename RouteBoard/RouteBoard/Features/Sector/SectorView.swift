//
//  SectorView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import GeneratedClient
import SwiftUI

struct WeatherInfoView: View {
  var body: some View {
    HStack {
      VStack {
        Image(systemName: "cloud.bolt.rain.fill")
          .font(.title)
          .foregroundColor(.white)
          .frame(height: 30)

        Text("12 °C")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }

      Spacer()

      VStack {
        Image(systemName: "wind")
          .font(.title)
          .foregroundColor(.white)
          .frame(height: 30)

        Text("18 km/h")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }

      Spacer()

      VStack {
        Image(systemName: "drop")
          .font(.title)
          .foregroundColor(.white)
          .frame(height: 30)

        Text("12%")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }
    }
    .padding(.horizontal, 40)
  }
}

struct SectorView: View {
  let sectorId: String

  @State private var isLoading: Bool = false
  @State private var showRoutes = false
  @State private var show = true
  @State private var sector: SectorDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let client = GetSectorDetailsClient()

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

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
    ApplyBackgroundColor(backgroundColors: [.newPrimaryColor, .newBackgroundGray]) {
      DetailsViewStateMachine(details: $sector, isLoading: $isLoading) {
        SectorTopContainerView(sector: sector) {
          DetectRoutesWrapper(routes: sectorRoutes) {
            ScrollView {
              VStack(spacing: 30) {
                SectorTopGradesSummaryContainer(sector: sector)
                Spacer()
              }
              .padding(.horizontal, 20)
              .padding(.top, 20)
              .background(Color.newPrimaryColor)

              ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
                VStack(spacing: 20) {
                  Spacer()

                  SectorLocationInfoView(sector: sector)

                  VStack(spacing: 30) {
                    SectorClimbTypeView()
                    SectorRoutesList(sector: sector)
                    SectorGradesView(sector: sector)

                    Spacer()
                  }
                  .padding(.top, 20)
                  .background(Color.newBackgroundGray)
                  .clipShape(
                    .rect(
                      topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                      topTrailingRadius: 40)
                  )
                }
                .background(.white)
                .clipShape(
                  .rect(
                    topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                    topTrailingRadius: 40)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
                .mask(
                  Rectangle().padding(.top, -40)
                )
              }
            }
          }
        }
      }
    }
    .detailsNavigationBar()
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
