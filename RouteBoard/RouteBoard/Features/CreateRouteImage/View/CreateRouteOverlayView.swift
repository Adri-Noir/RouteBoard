//
//  CreateRouteOverlayView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import SwiftUI

struct CreateRouteOverlayView<Content: View>: View {
    @State private var drawingPoints: RoutePoints = RoutePoints()
    @State private var imageMatrix: CVMap?
    @State private var points: [CGPoint] = []
    @State private var confirmOrAddNewRoute = false
    @State private var isCurrentlyDrawing = false
    
    var createRouteImageModel: CreateRouteImageModel
    @ViewBuilder var content: Content
    
    var confirmRoute: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    VStack {
                        Canvas { context, size in
                            if !points.isEmpty {
                                var path = Path()
                                path.move(to: points[0])
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                context.stroke(path, with: .color(.white), lineWidth: 5)
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button() {
                            imageMatrix = nil
                            points.removeAll()
                            drawingPoints.clearList()
                            createRouteImageModel.resumeViewFinder()
                            confirmOrAddNewRoute = false
                        } label: {
                            Text("Retake photo")
                        }
                        .foregroundStyle(.white)
                        .padding()
                        
                        Spacer()
                        
                        Button() {
                            points.removeAll()
                            drawingPoints.clearList()
                            confirmOrAddNewRoute = false
                        } label: {
                            Text("Redraw route line")
                                
                        }
                        .foregroundStyle(.white)
                        .padding()
                    }
                }
                .background(.black)
                .opacity(0.8)
                .frame(maxWidth: .infinity)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button() {
                        points.removeAll()
                        drawingPoints.clearList()
                        confirmOrAddNewRoute = false
                    } label: {
                        Text("Finish")
                            
                    }
                    .foregroundStyle(.white)
                    .padding()
                    
                    Spacer()
                }
            }
            .background(.black)
            .opacity(0.8)
            .frame(maxWidth: .infinity)
        }
        
        
    }
    
    var photoEditingView: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                VStack {
                    Canvas { context, size in
                        if !points.isEmpty {
                            var path = Path()
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                            context.stroke(path, with: .color(.white), lineWidth: 5)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                isCurrentlyDrawing = true
                                points.append(value.location)

                                let xCord = CInt(value.location.x) * CInt(imageMatrix?.cols ?? CInt(geometry.size.width)) / CInt(geometry.size.width)
                                let yCord = CInt(value.location.y) * CInt(imageMatrix?.rows ?? CInt(geometry.size.height)) / CInt(geometry.size.height)
                                drawingPoints.addPoint(point: Point2d(x: xCord, y: yCord))
                            }
                            .onEnded { value in
                                let image = OpenCVWrapper.createRouteLineImage(drawingPoints, picture: imageMatrix!)
                                confirmOrAddNewRoute = true
                                isCurrentlyDrawing = false
                            }
                    )
                    .onAppear {
                        isCurrentlyDrawing = false
                        DispatchQueue.main.async {
                            let renderer = ImageRenderer(content: createRouteImageModel.photoImage)
                            // Need to rotate because the picture will be landscape
                            if let uiImage = renderer.uiImage?.rotateImage90Degrees() {
                                imageMatrix = OpenCVWrapper.convertImage(toMat: uiImage)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
            if !isCurrentlyDrawing {
                VStack {
                    HStack {
                        Button() {
                            imageMatrix = nil
                            points.removeAll()
                            drawingPoints.clearList()
                            createRouteImageModel.resumeViewFinder()
                            confirmOrAddNewRoute = false
                        } label: {
                            Text("Retake photo")
                                
                        }
                        .foregroundStyle(.white)
                        .padding()
                        
                        Spacer()
                    }
                }
                .background(.black)
                .opacity(0.8)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var photoTakingView: some View {
        VStack {
            HStack {
                Button() {
                    Task {
                        await createRouteImageModel.takePhoto()
                    }
                } label: {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .resizable()
                        .scaledToFill()
                        
                }
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .padding()
                
                Spacer()
                
                PhotoCaptureButton {
                    Task {
                        await createRouteImageModel.takePhoto()
                    }
                }
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
                .padding(EdgeInsets(top: 10, leading: -60, bottom: 10, trailing: 0))
                
                Spacer()
            }
        }
        .background(.black)
        .opacity(0.8)
        .frame(maxWidth: .infinity)
        .onAppear(perform: drawingPoints.clearList)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if createRouteImageModel.isShowingPhoto {
                createRouteImageModel.photoImage?
                    .resizable()
                    .opacity(0.5)
            } else {
                content
            }
            
            
            if createRouteImageModel.isShowingPhoto {
                if confirmOrAddNewRoute {
                     confirmRoute
                } else {
                    photoEditingView
                }
            } else {
                photoTakingView
            }
        }
    }
}

extension UIImage {
    func rotateImage90Degrees() -> UIImage? {
        let size = self.size
        UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.height / 2, y: size.width / 2)
        context.rotate(by: .pi / 2)
        self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
