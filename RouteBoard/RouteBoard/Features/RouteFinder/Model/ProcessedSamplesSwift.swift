//
//  ProcessedSamplesSwift.swift
//  RouteBoard
//
//  Created with <3 on 30.06.2024..
//

import Foundation

@objc class CVMap: NSObject {
  @objc var rows: CInt
  @objc var cols: CInt
  @objc var type: CInt
  @objc var data: NSData
  @objc var step: CUnsignedLong

  @objc init(rows: CInt, cols: CInt, type: CInt, data: NSData, step: CUnsignedLong) {
    self.rows = rows
    self.cols = cols
    self.type = type
    self.data = data
    self.step = step
  }
}

@objc class Point2f: NSObject {
  @objc var x: Double
  @objc var y: Double

  @objc init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

@objc class KeyPoint: NSObject {
  @objc var pt: Point2f
  @objc var size: Double
  @objc var angle: Double
  @objc var response: Double
  @objc var octave: Int
  @objc var class_id: Int

  @objc init(
    x: Double, y: Double, size: Double, angle: Double, response: Double, octave: Int, class_id: Int
  ) {
    self.pt = Point2f(x: x, y: y)
    self.size = size
    self.angle = angle
    self.response = response
    self.octave = octave
    self.class_id = class_id
  }
}

@objc class ProcessedSample: NSObject {
  @objc var referenceKP: [KeyPoint]
  @objc var referenceDES: CVMap
  @objc var routeReference: UIImage
  @objc var routeId: CInt

  @objc init(referenceKP: [KeyPoint], referenceDES: CVMap, routeReference: UIImage, routeId: CInt) {
    self.referenceKP = referenceKP
    self.referenceDES = referenceDES
    self.routeReference = routeReference
    self.routeId = routeId
  }
}

@objc class ProcessedSamplesSwift: NSObject {
  @objc var processedSamples: [ProcessedSample]

  @objc init(processedSamples: [ProcessedSample]) {
    self.processedSamples = processedSamples
  }
}
