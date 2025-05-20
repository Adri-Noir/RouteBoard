// Created with <3 on 12.03.2025.

import GeneratedClient
import SwiftUI

typealias RoutePhoto = Components.Schemas.DetectRoutePhotoDto

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

  private static func downloadImage(url: String?) async -> UIImage? {
    guard let url = url else { return nil }
    guard let url = URL(string: url) else { return nil }
    let data = try? await URLSession.shared.data(from: url).0
    guard let imageData = data, let image = UIImage(data: imageData) else { return nil }
    return image
  }

  static func downloadPhoto(routePhotos: [RoutePhoto]) async -> [DetectSample] {
    var samples: [DetectSample] = []

    for routePhoto in routePhotos {
      let image = await downloadImage(url: routePhoto.image?.url)
      let pathImage = await downloadImage(url: routePhoto.pathLine?.url)

      guard let image = image, let pathImage = pathImage else { continue }

      if let routeId = routePhoto.routeId {
        let sample = DetectSample(route: image, path: pathImage, routeId: routeId)
        samples.append(sample)
      }
    }

    return samples
  }

  static func downloadPhotoToFile(url: String) async -> URL? {
    guard let url = URL(string: url) else { return nil }
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let docs = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)[0]
      let fileURL = docs.appendingPathComponent("\(UUID().uuidString).jpg")
      try data.write(to: fileURL)
      return fileURL
    } catch {
      print("Failed to download or save photo: \(error)")
      return nil
    }
  }
}
