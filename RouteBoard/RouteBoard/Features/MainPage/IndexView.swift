//
//  IndexView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//
import SwiftUI


struct IndexView: View {
    var body: some View {
        MainNavigation {
            ApplyBackgroundColor {
                VStack(alignment: .leading, spacing: 10) {
                    WelcomeTextView()
                    RecentAscentsView()
                    Spacer()
                }
                .padding(10)
            }
        }
    }
}

#Preview {
    IndexView()
}
