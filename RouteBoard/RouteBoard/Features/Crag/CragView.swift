//
//  CragView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.01.2025..
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
    ApplyBackgroundColor {
      DetailsViewStateMachine(details: $crag, isLoading: $isLoading) {
        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            ImageCarouselView(imagesNames: crag?.photos ?? [], height: 500)
              .cornerRadius(20)

            Text(crag?.name ?? "Crag")
              .frame(maxWidth: .infinity, alignment: .center)
              .font(.largeTitle)
              .fontWeight(.semibold)
              .foregroundStyle(.black)
              .padding()

            Text(crag?.description ?? "")
              .frame(maxWidth: .infinity, alignment: .center)
              .foregroundStyle(.black)
              .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 10))
          }
          .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
      }
    }
    .task {
      await getCrag(value: cragId)
    }

  }
}

#Preview {
  CragView(cragId: "db203ffb-0c58-4a4c-541b-08dcf8780e0a")
}
