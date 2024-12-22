//
//  CreateRouteImage.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 18.12.2024..
//

import opencv2

class CreateRouteImage {
    init() {}
    
    static func createRouteLineImage(points: [CGPoint], picture: UIImage) -> UIImage {
        let pictureMat = Mat(uiImage: picture);
        let lineMat = Mat.zeros(pictureMat.rows(), cols: pictureMat.cols(), type: pictureMat.type())
        
        for i in 0..<(points.count - 1) {
            let pt1 = points[i]
            let pt2 = points[i + 1]
            
            let point1 = Point(x: Int32(pt1.x), y: Int32(pt1.y))
            let point2 = Point(x: Int32(pt2.x), y: Int32(pt2.y))
            
            Imgproc.line(img: lineMat, pt1: point1, pt2: point2, color: Scalar(100, 100, 0, 255), thickness: 25)
        }
        
        return lineMat.toUIImage()
    }
}
