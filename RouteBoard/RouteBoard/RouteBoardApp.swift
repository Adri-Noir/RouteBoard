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
        // UINavigationBar.applyCustomAppearance()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Color(red: 0.94, green: 0.93, blue: 0.93)
                
                SectorView()
            }
        }
    }
}


fileprivate extension UINavigationBar {
    
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor(red: 0.94, green: 0.93, blue: 0.93, alpha: 1.0)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
