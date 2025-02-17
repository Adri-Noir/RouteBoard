//
//  ViewFinderView.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import SwiftUI

struct ViewFinderView: View {
    @Binding var image: Image?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    ViewFinderView(image: .constant(Image(systemName: "pencil")))
}
