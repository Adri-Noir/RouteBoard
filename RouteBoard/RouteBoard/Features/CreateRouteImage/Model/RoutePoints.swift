//
//  RoutePoints.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import Foundation

@objc class Point2d: NSObject {
    @objc var x: CInt;
    @objc var y: CInt;
    
    @objc init(x: CInt, y: CInt) {
        self.x = x
        self.y = y
    }
}

@objc class RoutePoints: NSObject {
    @objc var points: [Point2d];
    
    @objc override init() {
        self.points = Array()
    }
    
    @objc init(points: [Point2d]) {
        self.points = points
    }
    
    @objc func addPoint(point: Point2d) {
        points.append(point)
    }
    
    @objc func clearList() {
        points.removeAll()
    }
}
