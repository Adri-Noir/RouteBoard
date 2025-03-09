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
  @State private var errorMessage: String? = nil
  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let getCragDetailsClient = GetCragDetailsClient()

  init(cragId: String) {
    self.cragId = cragId
  }

  func getCrag(value: String) async {
    isLoading = true

    guard
      let cragDetails = await getCragDetailsClient.call(
        CragDetailsInput(id: value), authViewModel.getAuthData(), { errorMessage = $0 })
    else {
      isLoading = false
      return
    }

    self.crag = cragDetails
    isLoading = false
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      DetailsViewStateMachine(details: $crag, isLoading: $isLoading) {
        CragHeaderView(crag: crag) {
          VStack(spacing: 0) {
            VStack(spacing: 20) {
              Text(crag?.name ?? "")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
              CragTopInfoContainerView(crag: crag)
              Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
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
            .background(Color.newPrimaryColor)
          }
        }
      }
    }
    .navigationBarBackButtonHidden()
    .task {
      await getCrag(value: cragId)
    }
    .onDisappear {
      getCragDetailsClient.cancelRequest()
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
      CragView(cragId: "3eb16769-b6a3-4d1f-4411-08dd59ee505a")
    }
  }
}
