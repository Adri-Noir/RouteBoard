//
//  RouteLink.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 31.12.2024..
//

import SwiftUI

struct RouteLink<Content: View>: View {
    @Binding var routeId: String?
    @ViewBuilder var content: Content

    var body: some View {
        NavigationLink(destination: RouteView(routeId: routeId ?? "")) {
            content
        }
    }
}
