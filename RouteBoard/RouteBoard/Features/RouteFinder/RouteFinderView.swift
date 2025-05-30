//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

import GeneratedClient
import SwiftData
import SwiftUI

enum RouteFinderType {
  case manual
  case auto
}

enum RouteDetectionLOD {
  case low
  case medium
  case high
}

struct RouteFinderView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.isOfflineMode) private var isOfflineMode
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  var route: RouteDetails? = nil
  var offlineRoute: DownloadedRoute? = nil

  @State var routeFinderType: RouteFinderType = .manual
  @State var routeDetectionLOD: RouteDetectionLOD = .high
  @State var routeSamples: [DetectSample] = []
  @State private var isLoading = false

  @StateObject private var routeImageModel = RouteImageModel()

  init(route: RouteDetails) {
    self.route = route
  }

  init(offlineRoute: DownloadedRoute) {
    self.offlineRoute = offlineRoute
  }

  var body: some View {
    VStack(spacing: 12) {
      if !isLoading {
        HStack {
          Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
              .foregroundColor(.white)
          }

          Spacer()

          Menu {
            Button(action: {
              routeFinderType = .auto
              routeDetectionLOD = .medium
            }) {
              if routeFinderType == .auto {
                Label("Auto", systemImage: "checkmark")
              } else {
                Text("Auto")
              }
            }
            Button(action: {
              routeFinderType = .manual
              routeDetectionLOD = .high
            }) {
              if routeFinderType == .manual {
                Label("Manual", systemImage: "checkmark")
              } else {
                Text("Manual")
              }
            }
            Divider()
            // add 3 buttons to represent the 3 LODs for detecting routes
            Button(action: {
              routeDetectionLOD = .low
              routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: .low)
            }) {
              if routeDetectionLOD == .low {
                Label("Low", systemImage: "checkmark")
              } else {
                Text("Low")
              }
            }
            Button(action: {
              routeDetectionLOD = .medium
              routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: .medium)
            }) {
              if routeDetectionLOD == .medium {
                Label("Medium", systemImage: "checkmark")
              } else {
                Text("Medium")
              }
            }
            Button(action: {
              routeDetectionLOD = .high
              routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: .high)
            }) {
              if routeDetectionLOD == .high {
                Label("High", systemImage: "checkmark")
              } else {
                Text("High")
              }
            }
          } label: {
            Image(systemName: "gearshape.fill")
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(.white)
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)

        if routeFinderType == .auto {
          AutoRouteFinderView(
            routeImageModel: routeImageModel, routeDetectionLOD: $routeDetectionLOD)
        } else {
          ManualRouteFinderView(
            routeImageModel: routeImageModel,
            routeDetectionLOD: $routeDetectionLOD
          )
        }

        RouteFinderBottomInfoView(routeImageModel: routeImageModel)
      }

      if isLoading {
        ZStack {
          Color.black
            .ignoresSafeArea()

          VStack {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(1.5)

            Text("Loading route...")
              .foregroundColor(.white)
              .padding(.top, 20)
          }
        }
      }
    }
    .navigationBarHidden(true)
    .task {
      isLoading = true
      defer { isLoading = false }
      var allRoutes: [RouteDetails] = []
      var allDownloadedRoutes: [DownloadedRoute] = []
      if let offlineRoute = offlineRoute {
        allDownloadedRoutes = [offlineRoute]
        var samples: [DetectSample] = []
        for photo in offlineRoute.photos {
          if let imageUrlString = photo.imagePhoto?.url,
            let pathUrlString = photo.pathLinePhoto?.url,
            let imageUrl = URL(string: imageUrlString),
            let pathUrl = URL(string: pathUrlString),
            imageUrl.isFileURL,
            pathUrl.isFileURL,
            let uiRouteImage = UIImage(contentsOfFile: imageUrl.path),
            let uiPathImage = UIImage(contentsOfFile: pathUrl.path),
            let routeIdString = offlineRoute.id
          {
            let sample = DetectSample(
              route: uiRouteImage, path: uiPathImage, routeId: routeIdString)
            samples.append(sample)
          }
        }
        routeSamples = samples
        routeImageModel.setAvailableRoutes(routes: allRoutes, downloadedRoutes: allDownloadedRoutes)
        routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: routeDetectionLOD)
        return
      } else if let route = route {
        allRoutes = [route]
        if isOfflineMode {
          let routeId = route.id
          let fetchedRoutes = try? modelContext.fetch(
            FetchDescriptor<DownloadedRoute>(
              predicate: #Predicate<DownloadedRoute> { downloadedRoute in
                downloadedRoute.id == routeId
              })
          )
          if let localRoute = fetchedRoutes?.first {
            allDownloadedRoutes = [localRoute]
            var samples: [DetectSample] = []
            for photo in localRoute.photos {
              if let imageUrlString = photo.imagePhoto?.url,
                let pathUrlString = photo.pathLinePhoto?.url,
                let imageUrl = URL(string: imageUrlString),
                let pathUrl = URL(string: pathUrlString),
                imageUrl.isFileURL,
                pathUrl.isFileURL,
                let uiRouteImage = UIImage(contentsOfFile: imageUrl.path),
                let uiPathImage = UIImage(contentsOfFile: pathUrl.path),
                let routeIdString = localRoute.id
              {
                let sample = DetectSample(
                  route: uiRouteImage, path: uiPathImage, routeId: routeIdString)
                samples.append(sample)
              }
            }
            routeSamples = samples
          } else {
            routeSamples = []
          }
        } else {
          routeSamples = await PhotoDownloader.downloadRoutePhotos(
            routeId: route.id, authViewModel: authViewModel)
        }
        routeImageModel.setAvailableRoutes(routes: allRoutes, downloadedRoutes: allDownloadedRoutes)
        routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: routeDetectionLOD)
        return
      }
      routeImageModel.setAvailableRoutes(routes: allRoutes, downloadedRoutes: allDownloadedRoutes)
      routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: routeDetectionLOD)
    }
    .onAppear {
      Task {
        await routeImageModel.startCamera()
      }
    }
    .onDisappear {
      Task {
        await routeImageModel.stopCamera()
      }
    }

  }
}

struct AutoRouteFinderView: View {
  @ObservedObject var routeImageModel: RouteImageModel
  @Binding var routeDetectionLOD: RouteDetectionLOD

  var body: some View {
    ZStack {
      CameraPreview(source: routeImageModel.camera.previewSource)
        .background(.black)
        .onAppear {
          Task {
            await routeImageModel.handleCameraPreviewsProcessEveryFrame()
          }
        }

      routeImageModel.viewfinderImage?
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .onChange(of: routeDetectionLOD) { _, newValue in
      routeImageModel.resumeCameraPreviews(routeDetectionLOD: newValue)
    }
    .onAppear {
      routeImageModel.resumeCameraPreviews(routeDetectionLOD: routeDetectionLOD)
    }
    .onDisappear {
      routeImageModel.pauseCameraPreviews()
    }
  }
}

struct ManualRouteFinderView: View {
  @ObservedObject var routeImageModel: RouteImageModel
  @Binding var routeDetectionLOD: RouteDetectionLOD

  @State var manualCapturedImage: Image?
  @State var isTakingPhoto: Bool = false

  var body: some View {
    ZStack {
      if let manualCapturedImage = manualCapturedImage {
        GeometryReader { geometry in
          manualCapturedImage
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
      } else {
        CameraPreview(source: routeImageModel.camera.previewSource)
          .background(.black)
      }

      VStack {
        Spacer()
        if manualCapturedImage != nil {
          Button(action: {
            manualCapturedImage = nil
            // Clear detected routes when retaking
            routeImageModel.detectedRoute = nil
            routeImageModel.detectedDownloadedRoute = nil
          }) {
            Text("Retake Image")
              .font(.headline)
              .padding(.horizontal, 20)
              .padding(.vertical, 10)
              .background(Color.newPrimaryColor)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
          .padding(.bottom, 40)
        } else if !isTakingPhoto {
          ZStack {
            PhotoCaptureButton {
              Task {
                isTakingPhoto = true
                if let processedImage = await routeImageModel.takePhotoAndDetectRoute(
                  routeDetectionLOD: routeDetectionLOD)
                {
                  self.manualCapturedImage = Image(uiImage: processedImage)
                }
                isTakingPhoto = false
              }
            }
            .frame(width: 70, height: 70)
            if isTakingPhoto {
              Image(systemName: "hourglass")
                .foregroundColor(.black)
                .font(.system(size: 30))
            }
          }
          .padding(.bottom, 40)
        }
      }
      .frame(maxWidth: .infinity)
    }
  }
}
