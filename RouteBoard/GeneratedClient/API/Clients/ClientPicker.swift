//
//  ClientPicker.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

let IS_DEVELOPMENT = true

struct ClientPicker {
    static func getClient() -> Client {
        if (IS_DEVELOPMENT) {
            return DevClient.getClient()
        }
        return DevClient.getClient()
    }
}
