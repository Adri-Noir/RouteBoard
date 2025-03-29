// Created with <3 on 29.03.2025.

import Foundation

// SSL Security Options
public enum SSLSecurity {
  case secure
  case insecure
}

// URLSession factory
public class CustomClient {
  // We're using InsecureURLSessionDelegate from DevClient.swift
  // so we don't need to define our own delegate class

  // Create a URLSession with desired security settings (default to insecure)
  public static func createSession(security: SSLSecurity = .insecure) -> URLSession {
    let configuration = URLSessionConfiguration.default

    switch security {
    case .secure:
      // Standard secure session
      return URLSession(configuration: configuration)

    case .insecure:
      // Bypass SSL certificate validation using the existing InsecureURLSessionDelegate
      return URLSession(
        configuration: configuration,
        delegate: InsecureURLSessionDelegate(),
        delegateQueue: nil
      )
    }
  }
}
