//
//  ClientProtocol.swift
//  RouteBoard
//
//  Created with <3 on 25.12.2024..
//

import OpenAPIRuntime
import OpenAPIURLSession

protocol ClientProtocol {
  func getClient(_ token: String?) -> ClientWithSession
}
