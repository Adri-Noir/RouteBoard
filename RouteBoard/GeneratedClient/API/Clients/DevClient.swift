//
//  DevClient.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

import Foundation
import OpenAPIURLSession
import OpenAPIRuntime

final class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trust the server certificate regardless of its validity
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


class DevClient: ClientProtocol {
    static func getClient() -> Client {
        let session = URLSession(configuration: .default, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
        do {
            let server = try Servers.Server1.url()
            return Client(serverURL: server, transport: URLSessionTransport(configuration: .init(session: session)))
        } catch {
            fatalError("Could not create server URL: \(error)")
        }
    }
}
