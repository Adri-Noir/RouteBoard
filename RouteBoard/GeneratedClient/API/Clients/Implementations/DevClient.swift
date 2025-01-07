//
//  DevClient.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 25.12.2024..
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
  func urlSession(
    _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    // Trust the server certificate regardless of its validity
    completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
  }
}

class DevClient: ClientProtocol {
  private var _client: Client? = nil
  private var _token: String? = nil

  private func createNewClient(_ token: String?) -> Client {
    let session = URLSession(
      configuration: .default, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
    do {
      let server = try Servers.Server1.url()
      let client = Client(
        serverURL: server, transport: URLSessionTransport(configuration: .init(session: session)),
        middlewares: [AuthenticationMiddleware(value: token)])
      self._client = client
      self._token = token

      return client
    } catch {
      fatalError("Could not create server URL: \(error)")
    }
  }

  func getClient(_ token: String?) -> Client {
    guard let client = _client else {
      return createNewClient(token)
    }

    if _token != token {
      return createNewClient(token)
    }

    return client
  }
}
