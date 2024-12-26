//
//  WelcomeTextView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI


struct WelcomeTextView : View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Welcome Test!")
                .font(.title)
                .foregroundStyle(.black)
            Spacer()
        }
    }
}

#Preview {
    WelcomeTextView()
}
