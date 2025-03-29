// Created with <3 on 12.03.2025.

import GeneratedClient

typealias RoutePhoto = Components.Schemas.ExtendedRoutePhotoDto

class PhotoDownloader {
  static func downloadRoutePhotos(routeId: String, authViewModel: AuthViewModel) async
    -> [DetectSample]
  {
    let getRouteDetectionPhotosClient = GetRouteDetectionPhotosClient()
    let routePhotos = await getRouteDetectionPhotosClient.call(
      routeId, authViewModel.getAuthData())
    guard let routePhotos = routePhotos else { return [] }

    let samples = await downloadPhoto(routePhotos: routePhotos)
    return samples
  }

  static func downloadPhoto(routePhotos: [RoutePhoto]) async -> [DetectSample] {
    var samples: [DetectSample] = []

    for routePhoto in routePhotos {
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

    return samples
  }
}
