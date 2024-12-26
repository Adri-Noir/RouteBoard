//
//  MainNavigationView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//


import SwiftUI

struct MainNavigation: View {

    @State var selectedTab: Int = 0;

    var NotFoundView: some View {
        Text("View not found")
    }

    var body: some View {
        NavigationView {
            ApplyBackgroundColor {
                ZStack(alignment: .bottom) {
                    ZStack {
                        switch selectedTab {
                        case 0: IndexView().transition(.opacity)
                        case 1: GeneralSearchView().transition(.opacity)
                        default: NotFoundView.transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: selectedTab)

                    HStack {
                        Spacer()
                            .frame(width: 30)

                        MainNavigationButton(iconName: "house", text: "Home", tag: 0, selectedTab: $selectedTab)

                        Spacer()

                        MainNavigationButton(iconName: "magnifyingglass", text: "Search", tag: 1, selectedTab: $selectedTab)

                        Spacer()

                        MainNavigationButton(iconName: "person", text: "Profile", tag: 2, selectedTab: $selectedTab)

                        Spacer()
                            .frame(width: 30)
                    }
                    .background(Color.primaryColor)
                    .clipShape(Capsule())
                    .padding(.horizontal, 10)
                }
            }
        }
    }
}

#Preview {
    MainNavigation()
}
