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

  @State private var isLoading: Bool = false
  @State private var crag: CragDetails?

  @EnvironmentObject private var authViewModel: AuthViewModel

  private let getCragDetailsClient = GetCragDetailsClient()

  init(cragId: String) {
    self.cragId = cragId
  }

  func getCrag(value: String) async {
    isLoading = true

    guard
      let cragDetails = await getCragDetailsClient.call(
        CragDetailsInput(id: value), authViewModel.getAuthData())
    else {
      isLoading = false
      return
    }

    self.crag = cragDetails
    isLoading = false
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColors: [.newPrimaryColor, .newBackgroundGray]) {
      DetailsViewStateMachine(details: $crag, isLoading: $isLoading) {
        CragTopContainerView(crag: crag) {
          ScrollView {
            VStack(spacing: 30) {
              CragTopInfoContainerView(crag: crag)
              Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .background(Color.newPrimaryColor)

            ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
              VStack(spacing: 20) {
                CragGalleryView(crag: crag)
                  .padding(.horizontal, 20)
                CragMapView(crag: crag)
                  .padding(.horizontal, 20)
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
            }
          }
        }
      }
    }
    .detailsNavigationBar()
    .task {
      await getCrag(value: cragId)
    }

  }
}

#Preview {
  AuthInjectionMock {
    CragView(cragId: "db203ffb-0c58-4a4c-541b-08dcf8780e0a")
  }
}
