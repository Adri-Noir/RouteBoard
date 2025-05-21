// Created with <3 on 20.05.2025.

import GeneratedClient
import SwiftData

@Model
class DownloadedCrag {
  @Attribute(.unique) var id: String?
  var name: String?
  var descriptionText: String?
  var locationName: String?
  @Relationship var sectors: [DownloadedSector]
  @Relationship var photos: [DownloadedPhoto]

  init(
    id: String? = "",
    name: String? = nil,
    descriptionText: String? = nil,
    locationName: String? = nil,
    sectors: [DownloadedSector] = [],
    photos: [DownloadedPhoto] = []
  ) {
    self.id = id
    self.name = name
    self.descriptionText = descriptionText
    self.locationName = locationName
    self.sectors = sectors
    self.photos = photos
  }
}
