import Foundation
import GeneratedClient
import SwiftUI

typealias RoutePhoto = Components.Schemas.RoutePhotoDto

struct DetectRoutesWrapper<Content: View>: View {
  var routesPhotos: [RoutePhoto] = []
  @ViewBuilder var content: Content

  @State private var show: Bool = false
  @State private var routeSamples: [DetectSample] = [
    DetectSample(
      route: UIImage.init(named: "TestingSamples/homewall_image")!,
      path: UIImage.init(named: "TestingSamples/homewall_image_route")!, routeId: "1")
  ]

  init(routes: [RouteDetails], @ViewBuilder content: @escaping () -> Content) {
    self.routesPhotos = routes.flatMap { $0.routePhotos ?? [] }
    self.content = content()
  }

  init(routes: [SectorRoute], @ViewBuilder content: @escaping () -> Content) {
    self.routesPhotos = routes.flatMap { $0.routePhotos ?? [] }
    self.content = content()
  }

  private func downloadPhotos() async {
    var samples: [DetectSample] = []

    for routePhoto in routesPhotos {
      guard let imageStringUrl = routePhoto.image?.url else { continue }
      guard let url = URL(string: imageStringUrl) else { continue }
      let data = try? await URLSession.shared.data(from: url).0
      guard let imageData = data, let image = UIImage(data: imageData) else { continue }

      guard let pathStringUrl = routePhoto.pathLine?.url else { continue }
      guard let pathUrl = URL(string: pathStringUrl) else { continue }
      let pathData = try? await URLSession.shared.data(from: pathUrl).0
      guard let pathImageData = pathData, let pathImage = UIImage(data: pathImageData) else {
        continue
      }

      if let routeId = routePhoto.routeId {
        let sample = DetectSample(route: image, path: pathImage, routeId: routeId)
        samples.append(sample)
      }
    }

    routeSamples = samples
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      content

      if !routeSamples.isEmpty {
        Button {
          show.toggle()
        } label: {
          Image(systemName: "eye")
            .font(.title.weight(.semibold))
            .padding()
            .background(Color.newPrimaryColor)
            .foregroundColor(.white)
            .clipShape(Circle())
        }
        .padding()
        .fullScreenCover(isPresented: $show) {
          RouteFinderView(routeSamples: routeSamples)
        }
      }

    }
    .task(priority: .background) {
      // await downloadPhotos()
    }
  }
}
