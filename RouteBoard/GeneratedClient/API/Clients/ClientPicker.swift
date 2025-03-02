//
//  ClientPicker.swift
//  RouteBoard
//
//  Created with <3 on 25.12.2024..
//

let IS_DEVELOPMENT = true
// let devClient = DevClient()

struct ClientPicker {
  func getClient(token: String?) -> Client {
    if IS_DEVELOPMENT {
      return DevClient().getClient(token)
    }
    return DevClient().getClient(token)
  }
}
