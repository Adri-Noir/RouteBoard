//
//  DevClient.swift
//  RouteBoard
//
//  Created with <3 on 25.12.2024..
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

public struct ClientWithSession {
  let client: Client
  let session: URLSession

  public func cancelRequest() {
    session.invalidateAndCancel()
  }
}

class DevClient: ClientProtocol {
  private var _client: ClientWithSession? = nil
  private var _token: String? = nil

  private func createNewClient(_ token: String?) -> ClientWithSession {
    let session = URLSession(
      configuration: .default, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
    do {
      let server = try Servers.Server1.url()
      let client = Client(
        serverURL: server, transport: URLSessionTransport(configuration: .init(session: session)),
        middlewares: [AuthenticationMiddleware(value: token)])
      self._client = ClientWithSession(client: client, session: session)
      self._token = token

      return ClientWithSession(client: client, session: session)
    } catch {
      fatalError("Could not create server URL: \(error)")
    }
  }

  func getClient(_ token: String?) -> ClientWithSession {
    guard let client = _client else {
      return createNewClient(token)
    }

    if _token != token {
      return createNewClient(token)
    }

    return client
  }
}
