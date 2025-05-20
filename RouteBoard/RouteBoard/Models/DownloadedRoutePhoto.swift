// Created with <3 on 18.05.2025.

import SwiftData
import SwiftUI

@Model
class DownloadedRoutePhoto {
  @Attribute(.unique) var id: String?
  var pathLineUrl: URL?
  var imageUrl: URL?
  var combinedImageUrl: URL?

  init(
    id: String? = nil,
    pathLineUrl: URL? = nil,
    imageUrl: URL? = nil,
    combinedImageUrl: URL? = nil
  ) {
    self.id = id
    self.pathLineUrl = pathLineUrl
    self.imageUrl = imageUrl
    self.combinedImageUrl = combinedImageUrl
  }
}
