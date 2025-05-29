//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created with <3 on 29.06.2024..
//

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

  var routeId: String? = nil

  @State var routeFinderType: RouteFinderType = .manual
  @State var routeDetectionLOD: RouteDetectionLOD = .medium
  @State var routeSamples: [DetectSample] = []
  @State private var isLoading = false

  @StateObject private var routeImageModel = RouteImageModel()
  @State private var manualCapturedImage: Image? = nil
  @State private var manualClosestRouteId: Int? = nil

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
            Button(action: { routeFinderType = .auto }) {
              if routeFinderType == .auto {
                Label("Auto", systemImage: "checkmark")
              } else {
                Text("Auto")
              }
            }
            Button(action: { routeFinderType = .manual }) {
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
            manualCapturedImage: $manualCapturedImage,
            manualClosestRouteId: $manualClosestRouteId,
            routeDetectionLOD: $routeDetectionLOD,
          )
        }
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
      if let routeId = routeId {
        if isOfflineMode {
          // Load samples from local storage
          let fetchedRoutes = try? modelContext.fetch(
            FetchDescriptor<DownloadedRoute>(
              predicate: #Predicate<DownloadedRoute> { $0.id == routeId })
          )
          if let localRoute = fetchedRoutes?.first {
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
            routeId: routeId, authViewModel: authViewModel)
        }
        routeImageModel.processSamples(samples: routeSamples, routeDetectionLOD: routeDetectionLOD)
        return
      }

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

    RouteFinderBottomInfoView(routeImageModel: routeImageModel)
  }
}

struct ManualRouteFinderView: View {
  @ObservedObject var routeImageModel: RouteImageModel
  @Binding var manualCapturedImage: Image?
  @Binding var manualClosestRouteId: Int?
  @Binding var routeDetectionLOD: RouteDetectionLOD

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
            manualClosestRouteId = nil
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
                if let uiImage = await routeImageModel.camera.takePhoto() {
                  let processed = routeImageModel.processInputSamples
                    .detectRoutesAndAddOverlay(
                      inputFrame: uiImage,
                      options: DetectOptions(
                        shouldAddFrameToOutput: true, routeDetectionLOD: routeDetectionLOD))
                  self.manualCapturedImage = Image(uiImage: processed.frame)
                  self.manualClosestRouteId = Int(processed.routeId)
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

#Preview {
  RouteFinderView(routeSamples: [
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/pikachu")!,
      path: UIImage.init(named: "TestingSamples/limski/pikachu_path")!, routeId: "1"),
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/hobotnica")!,
      path: UIImage.init(named: "TestingSamples/limski/hobotnica_path")!, routeId: "2"),
    DetectSample(
      route: UIImage.init(named: "TestingSamples/limski/list")!,
      path: UIImage.init(named: "TestingSamples/limski/list_path")!, routeId: "3"),
  ])
}
