//
//  ResultTypeLinkPicker.swift
//  RouteBoard
//
//  Created with <3 on 31.12.2024..
//

import GeneratedClient
import SwiftUI

struct ResultTypeLinkPicker<Content: View>: View {
  var result: SearchResultDto
  @ViewBuilder var content: Content

  var body: some View {
    switch result.entityType {
    case .Sector:
      if let sectorId = result.sectorId {
        SectorLink(sectorId: sectorId) {
          content
        }
      } else {
        content
      }
    case .Route:
      if let routeId = result.routeId {
        RouteLink(routeId: routeId) {
          content
        }
      } else {
        content
      }
    case .Crag:
      if let cragId = result.cragId {
        CragLink(cragId: cragId) {
          content
        }
      } else {
        content
      }
    case .UserProfile:
      if let userId = result.profileUserId {
        UserLink(userId: userId) {
          content
        }
      } else {
        content
      }
    default:
      content
    }
  }
}
