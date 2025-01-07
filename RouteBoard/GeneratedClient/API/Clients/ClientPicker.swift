//
//  ClientPicker.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

let IS_DEVELOPMENT = true
let devClient = DevClient()

struct ClientPicker {
  func getClient(token: String?) -> Client {
    if IS_DEVELOPMENT {
      return devClient.getClient(token)
    }
    return devClient.getClient(token)
  }
}
