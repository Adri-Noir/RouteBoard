//
//  CreateRouteImage.swift
//  RouteBoard
//
//  Created with <3 on 18.12.2024..
//

import opencv2

class CreateRouteImage {
  init() {}

  static func createRouteLineImage(points: [CGPoint], picture: UIImage) -> UIImage {
    let pictureMat = Mat(uiImage: picture)
    let lineMat = Mat.zeros(pictureMat.rows(), cols: pictureMat.cols(), type: pictureMat.type())

    if points.count < 2 {
      return lineMat.toUIImage()
    }

    let pointsVec = points.map { Point(x: Int32($0.x), y: Int32($0.y)) }

    Imgproc.polylines(
      img: lineMat,
      pts: [pointsVec],
      isClosed: false,
      color: Scalar(0, 0, 0, 255),
      thickness: 65
    )

    Imgproc.polylines(
      img: lineMat,
      pts: [pointsVec],
      isClosed: false,
      color: Scalar(255, 0, 0, 255),
      thickness: 55
    )

    return lineMat.toUIImage()
  }
}
