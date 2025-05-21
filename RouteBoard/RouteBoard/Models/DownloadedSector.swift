// Created with <3 on 20.05.2025.

import GeneratedClient
import SwiftData

@Model
class DownloadedSector {
  @Attribute(.unique) var id: String?
  var name: String?
  var descriptionText: String?
  var location: Components.Schemas.PointDto?
  @Relationship var photos: [DownloadedPhoto]
  @Relationship var routes: [DownloadedRoute]
  @Relationship(inverse: \DownloadedCrag.sectors) var crag: DownloadedCrag?
  var cragId: String?
  var cragName: String?

  init(
    id: String? = "",
    name: String? = nil,
    descriptionText: String? = nil,
    location: Components.Schemas.PointDto? = nil,
    photos: [DownloadedPhoto] = [],
    routes: [DownloadedRoute] = [],
    cragId: String? = nil,
    cragName: String? = nil
  ) {
    self.id = id
    self.name = name
    self.descriptionText = descriptionText
    self.location = location
    self.photos = photos
    self.routes = routes
    self.cragId = cragId
    self.cragName = cragName
  }
}
