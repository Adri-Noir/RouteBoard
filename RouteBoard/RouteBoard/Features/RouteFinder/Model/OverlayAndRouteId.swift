//
//  OverlayAndRouteId.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 10.07.2024..
//

import Foundation

@objc class OverlayAndRouteId: NSObject {
    @objc var overlay: CVMap;
    @objc var routeId: CInt;
    
    @objc init(overlay: CVMap, routeId: CInt) {
        self.overlay = overlay
        self.routeId = routeId
    }
}
