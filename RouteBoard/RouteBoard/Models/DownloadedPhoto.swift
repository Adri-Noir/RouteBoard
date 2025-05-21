// Created with <3 on 20.05.2025.

import SwiftData

@Model
class DownloadedPhoto {
  @Attribute(.unique) var id: String?
  var url: String?
  @Relationship(inverse: \DownloadedCrag.photos) var crag: DownloadedCrag?
  @Relationship(inverse: \DownloadedSector.photos) var sector: DownloadedSector?
  @Relationship(inverse: \DownloadedRoutePhoto.pathLinePhoto) var routePhotoPathLine:
    DownloadedRoutePhoto?
  @Relationship(inverse: \DownloadedRoutePhoto.imagePhoto) var routePhotoImage:
    DownloadedRoutePhoto?
  @Relationship(inverse: \DownloadedRoutePhoto.combinedImagePhoto) var routePhotoCombined:
    DownloadedRoutePhoto?

  init(id: String? = nil, url: String? = nil) {
    self.id = id
    self.url = url
  }
}
