//
//  RoutePoints.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import Foundation
import opencv2

class RoutePoints: NSObject {
    var points: [Point2d];
    
    override init() {
        self.points = Array()
    }
    
    init(points: [Point2d]) {
        self.points = points
    }
    
    func addPoint(point: Point2d) {
        points.append(point)
    }
    
    func clearList() {
        points.removeAll()
    }
}
