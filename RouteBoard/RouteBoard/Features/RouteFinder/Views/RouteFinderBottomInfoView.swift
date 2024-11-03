//
//  RouteFinderBottomInfoView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 03.07.2024..
//

import SwiftUI

struct RouteFinderBottomInfoView: View {
    @ObservedObject var routeImageModel: RouteImageModel;
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button() {
                    routeImageModel.camera.stop()
                    dismiss()
                } label: {
                    Text("Close")
                }
                Spacer()
                Text("Looking at route: \(routeImageModel.closestRouteId ?? -1)")
            }
            .padding()
            
        }
        .background(.black)
        .opacity(0.8)
        .frame(maxWidth: .infinity)
    }
}
