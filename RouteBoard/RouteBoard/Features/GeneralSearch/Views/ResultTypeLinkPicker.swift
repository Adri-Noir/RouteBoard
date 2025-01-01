//
//  ResultTypeLinkPicker.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 31.12.2024..
//

import SwiftUI
import GeneratedClient

struct ResultTypeLinkPicker<Content: View>: View {
    @Binding var result: GetSearchResults
    @ViewBuilder var content: Content


    var body: some View {
        switch result._type {
        case .Sector:
            SectorLink(sectorId: $result.id) {
                content
            }
        case .Route:
            RouteLink(routeId: $result.id) {
                content
            }
        case .Crag:
            CragLink(cragId: $result.id) {
                content
            }
        default:
            RouteLink(routeId: $result.id) {
                content
            }

        }
    }
}
