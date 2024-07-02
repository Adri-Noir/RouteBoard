//
//  ImageCarouselView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import SwiftUI

struct ImageCarouselView: View {
    var imagesNames: [String]
    var height: CGFloat = 300;
    @State private var currentIndex = 0
    
    init(imagesNames: [String], height: CGFloat) {
        self.imagesNames = imagesNames;
        self.height = height;
    }
    
    init(imagesNames: [String]) {
        self.imagesNames = imagesNames;
    }
    
    var body: some View {
        ZStack{
            TabView(selection : $currentIndex){
                ForEach(0..<imagesNames.count, id: \.self){ index in
                    Image("\(imagesNames[index])")
                        .resizable()
                        .scaledToFill()
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(
                .page(backgroundDisplayMode: .always)
            )
        }
        .frame(height: height)
    }
    
}

#Preview {
    ImageCarouselView(imagesNames: ["TestingSamples/r3", "TestingSamples/r2"])
}
