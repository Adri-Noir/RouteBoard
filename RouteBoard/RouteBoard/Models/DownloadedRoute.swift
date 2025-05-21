// Created with <3 on 18.05.2025.

import GeneratedClient
import SwiftData

@Model
class DownloadedRoute {
  @Attribute(.unique) var id: String?
  var name: String?
  var descriptionText: String?
  var grade: Components.Schemas.ClimbingGrade?
  var createdAt: Date?
  var routeType: [Components.Schemas.RouteType]?
  var length: Int?
  var sectorId: String?
  var sectorName: String?
  var cragId: String?
  var cragName: String?
  @Relationship var photos: [DownloadedRoutePhoto]
  @Relationship(inverse: \DownloadedSector.routes) var sector: DownloadedSector?

  init(
    id: String? = "",
    name: String? = nil,
    descriptionText: String? = nil,
    grade: Components.Schemas.ClimbingGrade? = nil,
    createdAt: Date? = nil,
    routeType: [Components.Schemas.RouteType]? = nil,
    length: Int? = nil,
    sectorId: String? = nil,
    sectorName: String? = nil,
    cragId: String? = nil,
    cragName: String? = nil,
    photos: [DownloadedRoutePhoto] = []
  ) {
    self.id = id
    self.name = name
    self.descriptionText = descriptionText
    self.grade = grade
    self.createdAt = createdAt
    self.routeType = routeType
    self.length = length
    self.sectorId = sectorId
    self.sectorName = sectorName
    self.cragId = cragId
    self.cragName = cragName
    self.photos = photos
  }
}
