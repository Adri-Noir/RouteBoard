//
//  CragLink.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.01.2025..
//

import SwiftUI

struct CragLink<Content: View>: View {
    @Binding var cragId: String?
    @ViewBuilder var content: Content

    var body: some View {
        NavigationLink(destination: CragView(cragId: cragId ?? "")) {
            content
        }
    }
}
