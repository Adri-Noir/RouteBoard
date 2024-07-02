//
//  RouteBoardApp.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import SwiftUI

@main
struct RouteBoardApp: App {
    
    init() {
        UINavigationBar.applyCustomAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            SectorView()
        }
    }
}


fileprivate extension UINavigationBar {
    
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
