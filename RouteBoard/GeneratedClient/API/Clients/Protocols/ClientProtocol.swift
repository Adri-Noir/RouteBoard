//
//  ClientProtocol.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

import OpenAPIRuntime
import OpenAPIURLSession

protocol ClientProtocol {
  func getClient(_ token: String?) -> Client
}
