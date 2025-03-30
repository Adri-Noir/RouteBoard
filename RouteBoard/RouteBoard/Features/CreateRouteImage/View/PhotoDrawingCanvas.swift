//
//  PhotoDrawingCanvas.swift
//  RouteBoard
//
//  Created with <3 on 21.12.2024..
//

import SwiftUI

struct PhotoDrawingCanvas: View {
  @ObservedObject var createRouteImageModel: CreateRouteImageModel

  var body: some View {
    Canvas { context, size in
      if !createRouteImageModel.canvasPoints.isEmpty {
        var path = Path()
        path.move(to: createRouteImageModel.canvasPoints[0])
        for point in createRouteImageModel.canvasPoints.dropFirst() {
          path.addLine(to: point)
        }

        context.stroke(path, with: .color(.black), lineWidth: 10)
        context.stroke(path, with: .color(.red), lineWidth: 8)
      }
    }
  }
}
