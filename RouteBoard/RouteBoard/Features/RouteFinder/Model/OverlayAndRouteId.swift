//
//  OverlayAndRouteId.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 10.07.2024..
//

import Foundation

@objc class OverlayAndRouteId: NSObject {
    @objc var overlayedImage: UIImage;
    @objc var routeId: CInt;
    
    @objc init(overlayedImage: UIImage, routeId: CInt) {
        self.overlayedImage = overlayedImage
        self.routeId = routeId
    }
}
