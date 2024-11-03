//
//  RouteAscentView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI

public struct RouteAscentView: View {
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("TestingSamples/limski/pikachu")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 250)
                .cornerRadius(10)
            // darken the image so the text pops out more
                Color.black.opacity(0.35)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text("Route")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("This is a sample.")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(5)
        }
    }
}
