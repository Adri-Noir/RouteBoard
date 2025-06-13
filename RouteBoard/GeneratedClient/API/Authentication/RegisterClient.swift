//
//  RegisterClient.swift
//  RouteBoard
//
//  Created with <3 on 07.04.2025..
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public struct RegisterInput {
  public let email: String
  public let username: String
  public let password: String
  public let firstName: String?
  public let lastName: String?
  public let dateOfBirth: Date?
  public let profilePhoto: Data?

  public init(
    email: String,
    username: String,
    password: String,
    firstName: String? = nil,
    lastName: String? = nil,
    dateOfBirth: Date? = nil,
    profilePhoto: Data? = nil
  ) {
    self.email = email
    self.username = username
    self.password = password
    self.firstName = firstName
    self.lastName = lastName
    self.dateOfBirth = dateOfBirth
    self.profilePhoto = profilePhoto
  }
}

public typealias RegisteredUser = Components.Schemas.LoggedInUserDto

public class RegisterClient: NonAuthenticatedClientProvider {
  public typealias T = RegisterInput
  public typealias R = RegisteredUser?

  private func createMultipartFormData(data: RegisterInput, boundary: String) -> Data {
    var formData = Data()

    // Add email
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append("Content-Disposition: form-data; name=\"Email\"\r\n\r\n".data(using: .utf8)!)
    formData.append(data.email.data(using: .utf8)!)

    // Add username
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append("Content-Disposition: form-data; name=\"Username\"\r\n\r\n".data(using: .utf8)!)
    formData.append(data.username.data(using: .utf8)!)

    // Add password
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append("Content-Disposition: form-data; name=\"Password\"\r\n\r\n".data(using: .utf8)!)
    formData.append(data.password.data(using: .utf8)!)

    // Add first name if available
    if let firstName = data.firstName {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"FirstName\"\r\n\r\n".data(using: .utf8)!)
      formData.append(firstName.data(using: .utf8)!)
    }

    // Add last name if available
    if let lastName = data.lastName {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"LastName\"\r\n\r\n".data(using: .utf8)!)
      formData.append(lastName.data(using: .utf8)!)
    }

    // Add date of birth if available
    if let dateOfBirth = data.dateOfBirth {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime]
      let dateString = formatter.string(from: dateOfBirth)

      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"DateOfBirth\"\r\n\r\n".data(using: .utf8)!)
      formData.append(dateString.data(using: .utf8)!)
    }

    // Add profile photo if available
    if let profilePhoto = data.profilePhoto {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"ProfilePhoto\"; filename=\"photo.jpeg\"\r\n".data(
          using: .utf8)!)
      formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
      formData.append(profilePhoto)
    }

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    return formData
  }

  private var session: URLSession?

  public func call(_ data: RegisterInput, _ errorHandler: ((_ message: String) -> Void)? = nil)
    async
    -> RegisteredUser?
  {
    do {
      // Create URLSession using CustomClient
      let session = CustomClient.createSession()
      self.session = session

      // Create boundary and multipart form data
      let boundary = UUID().uuidString
      let formData = createMultipartFormData(data: data, boundary: boundary)

      // Create URL and request
      guard let baseURL = try? Servers.Server1.url(),
        let url = URL(string: "/api/Authentication/register", relativeTo: baseURL)
      else {
        errorHandler?("Failed to create URL")
        return nil
      }

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue(
        "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      // Upload request
      let (responseData, response) = try await session.upload(for: request, from: formData)

      // Check response
      guard let httpResponse = response as? HTTPURLResponse else {
        errorHandler?("Invalid response")
        return nil
      }

      // Handle response codes
      switch httpResponse.statusCode {
      case 200:
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          return try decoder.decode(RegisteredUser.self, from: responseData)
        } catch {
          errorHandler?("Failed to decode response: \(error.localizedDescription)")
          return nil
        }

      case 400:
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          logBadRequest("RegisterClient")
          errorHandler?(problemDetails.detail ?? "Bad request")
        } catch {
          logBadRequest("RegisterClient")
          errorHandler?("Bad request")
        }

      case 401:
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          errorHandler?(problemDetails.detail ?? "Unauthorized")
        } catch {
          errorHandler?("Unauthorized")
        }

      case 409:
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          errorHandler?(problemDetails.detail ?? "User already exists")
        } catch {
          errorHandler?("User already exists")
        }

      default:
        handleUndocumented(errorHandler)
      }
    } catch {
      // Log error but don't call errorHandler if it's a cancellation
      if (error as NSError).code != NSURLErrorCancelled {
        errorHandler?(error.localizedDescription)
      }
    }

    return nil
  }

  public func cancel() {
    session?.invalidateAndCancel()
    session = nil
  }
}
