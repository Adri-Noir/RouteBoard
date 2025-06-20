// Created with <3 on 05.04.2025.

import GeneratedClient
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
  case register
  case map
  case userDetails(id: String)
  case createRouteImage(routeId: String)
  case routeLogAscent(routeId: String, routeGrade: Components.Schemas.ClimbingGrade?)
  case editCrag(cragDetails: CreateCragOutput)
  case editSector(sectorDetails: CreateSectorOutput)
  case editRoute(routeDetails: RouteDetails)
  case generalSearch
  case offlineMode
  case offlineRoute(routeId: String)
  case offlineCrag(cragId: String)
  case editUser
}

enum Routes {
  static func routerReturner(path: NavigationPaths) -> some View {
    switch path {
    case .main:
      return AnyView(MainNavigationView())
    case .registeredUser:
      return AnyView(RegisteredUserView())
    case .cragDetails(let id):
      return AnyView(CragView(cragId: id).offlineMode(false))
    case .sectorDetails(let sectorId):
      return AnyView(CragView(sectorId: sectorId).offlineMode(false))
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
    case .register:
      return AnyView(UserRegisterView())
    case .map:
      return AnyView(MapView())
    case .userDetails(let id):
      return AnyView(UserView(userId: id))
    case .createRouteImage(let routeId):
      return AnyView(CreateRouteImageView(routeId: routeId))
    case .routeLogAscent(let routeId, let routeGrade):
      return AnyView(RouteLogAscent(routeId: routeId, routeGrade: routeGrade))
    case .editCrag(let cragDetails):
      return AnyView(CreateCragView(cragDetails: cragDetails))
    case .editSector(let sectorDetails):
      return AnyView(CreateSectorView(sectorDetails: sectorDetails))
    case .editRoute(let routeDetails):
      return AnyView(CreateRouteView(routeDetails: routeDetails))
    case .generalSearch:
      return AnyView(GeneralSearchView())
    case .offlineMode:
      return AnyView(OfflineModeView())
    case .offlineRoute(let routeId):
      return AnyView(OfflineRouteView(routeId: routeId))
    case .offlineCrag(let cragId):
      return AnyView(CragView(cragId: cragId).offlineMode(true))
    case .editUser:
      return AnyView(EditUserView())
    }
  }
}
