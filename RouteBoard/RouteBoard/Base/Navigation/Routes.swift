// Created with <3 on 05.04.2025.

import SwiftUI

enum NavigationPaths: Hashable {
  case main
  case registeredUser
  case createCrag
  case createSector(cragId: String)
  case createRoute(sectorId: String)
  case cragDetails(id: String)
  case sectorDetails(sectorId: String)
  case routeDetails(id: String)
  case login
  case map
  case userDetails(id: String)
  case createRouteImage(routeId: String)
}

enum Routes {
  static func routerReturner(path: NavigationPaths) -> some View {
    switch path {
    case .main:
      return AnyView(NewMainNavigationView())
    case .registeredUser:
      return AnyView(RegisteredUserView())
    case .cragDetails(let id):
      return AnyView(CragView(cragId: id))
    case .sectorDetails(let sectorId):
      return AnyView(CragView(sectorId: sectorId))
    case .routeDetails(let id):
      return AnyView(RouteView(routeId: id))
    case .createCrag:
      return AnyView(CreateCragView())
    case .createSector(let cragId):
      return AnyView(CreateSectorView(cragId: cragId))
    case .createRoute(let sectorId):
      return AnyView(CreateRouteView(sectorId: sectorId))
    case .login:
      return AnyView(UserLoginView())
    case .map:
      return AnyView(MapView())
    case .userDetails(let id):
      return AnyView(UserView(userId: id))
    case .createRouteImage(let routeId):
      return AnyView(CreateRouteImageView(routeId: routeId))
    }
  }
}
