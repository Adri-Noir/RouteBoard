//
//  SectorView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import SwiftUI
import GeneratedClient

struct SectorView: View {
    let sectorId: String

    @State private var isLoading: Bool = false
    @State private var showRoutes = false
    @State private var sector: SectorDetails?

    private let client = GetSectorDetailsClient()

    init(sectorId: String) {
        self.sectorId = sectorId
    }

    func getSector(value: String) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // TODO: Implement better error handling for sector details
        guard let sectorDetails = await client.getSectorDetails(sectorId: value) else {
            print("no sector found for \(value)")
            isLoading = false
            return;
        }

        sector = sectorDetails;
        isLoading = false
    }

    @ViewBuilder
    var body: some View {
        NavigationStack {
            ApplyBackgroundColor {
                SectorViewState(sectorDetails: $sector, isLoading: $isLoading) {
                    DetectRoutesWrapper {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ImageCarouselView(imagesNames: ["TestingSamples/r3", "TestingSamples/flok"], height: 500)
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

                                InformationRectanglesView(handleOpenRoutesView: {
                                    showRoutes = true
                                }, handleLike: {
                                    print("liked sector")
                                }, ascentsGraph: {
                                    Text("Ascents")
                                }, gradesGraphModel: GradesGraphModel(grades: [GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3), GradeCount(grade: "6a", count: 1)]))

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
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
                    .popover(isPresented: $showRoutes) {
                        RoutesListView(routes: [SimpleRoute(id: "1", name: "Apaches", grade: "6b", numberOfAscents: 1)])
                    }
                }
            }

        }
        .task(priority: .userInitiated) {
            await getSector(value: sectorId)
        }
    }
}


#Preview {
    SectorView(sectorId: "d9872fa7-8859-410e-9199-08dcf8780f2f")
}
