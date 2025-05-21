// Created with <3 on 18.05.2025.

import SwiftData
import SwiftUI

@Model
class DownloadedRoutePhoto {
  @Attribute(.unique) var id: String?
  @Relationship var pathLinePhoto: DownloadedPhoto?
  @Relationship var imagePhoto: DownloadedPhoto?
  @Relationship var combinedImagePhoto: DownloadedPhoto?

  init(
    id: String? = nil,
    pathLinePhoto: DownloadedPhoto? = nil,
    imagePhoto: DownloadedPhoto? = nil,
    combinedImagePhoto: DownloadedPhoto? = nil
  ) {
    self.id = id
    self.pathLinePhoto = pathLinePhoto
    self.imagePhoto = imagePhoto
    self.combinedImagePhoto = combinedImagePhoto
  }
}
