//
//  ImportSamplesSwift.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 30.06.2024..
//

import Foundation

@objc class Sample: NSObject {
    @objc var route: UIImage;
    @objc var path: UIImage;
    @objc var routeId: CInt
    
    @objc init(route: UIImage, path: UIImage, routeId: CInt) {
        self.route = route
        self.path = path
        self.routeId = routeId
    }
}


@objc class ImportSamplesSwift: NSObject {
    @objc var samples: [Sample];
    
    @objc init(samples: [Sample]) {
        self.samples = samples
    }
}
