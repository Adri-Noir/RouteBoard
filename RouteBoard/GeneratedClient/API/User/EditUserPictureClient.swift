// Created with <3 on 28.05.2025.

import OpenAPIURLSession

public struct EditUserPictureInput {
  public let userId: String
  public let photo: Data

  public init(userId: String, photo: Data) {
    self.userId = userId
    self.photo = photo
  }
}

public class EditUserPictureClient: AuthenticatedClientProvider {
  public typealias T = EditUserPictureInput
  public typealias R = Bool

  private func createMultipartFormData(data: EditUserPictureInput, boundary: String) -> Data {
    var formData = Data()

    // Add user ID
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append("Content-Disposition: form-data; name=\"UserId\"\r\n\r\n".data(using: .utf8)!)
    formData.append(data.userId.data(using: .utf8)!)

    // Add photo
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append(
      "Content-Disposition: form-data; name=\"Photo\"; filename=\"photo.jpeg\"\r\n".data(
        using: .utf8)!)
    formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    formData.append(data.photo)

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    return formData
  }

  private var session: URLSession?

  public func call(
    _ data: EditUserPictureInput, _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> Bool {
    do {
      // Create URLSession using CustomClient
      let session = CustomClient.createSession()
      self.session = session

      // Create boundary and multipart form data
      let boundary = UUID().uuidString
      let formData = createMultipartFormData(data: data, boundary: boundary)

      // Create URL and request
      guard let baseURL = try? Servers.Server1.url(),
        let url = URL(string: "/api/User/photo", relativeTo: baseURL)
      else {
        errorHandler?("Failed to create URL")
        return false
      }

      var request = URLRequest(url: url)
      request.httpMethod = "PUT"
      request.setValue(
        "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      // Add authorization header
      if let token = authData.token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }

      // Upload request
      let (responseData, response) = try await session.upload(for: request, from: formData)

      // Check response
      guard let httpResponse = response as? HTTPURLResponse else {
        errorHandler?("Invalid response")
        return false
      }

      // Handle response codes
      switch httpResponse.statusCode {
      case 200:
        return true

      case 400:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleBadRequest(problemDetails, "EditUserPictureClient", errorHandler)
        } catch {
          handleBadRequestString("Bad request", "EditUserPictureClient", errorHandler)
        }
        return false

      case 401:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          await handleUnauthorize(problemDetails, authData, errorHandler)
        } catch {
          await handleUnauthorize(nil, authData, errorHandler)
        }
        return false

      default:
        handleUndocumented(errorHandler)
        return false
      }
    } catch {
      // Log error but don't call errorHandler if it's a cancellation
      if (error as NSError).code != NSURLErrorCancelled {
        errorHandler?(error.localizedDescription)
      }
      return false
    }
  }

  public func cancel() {
    session?.invalidateAndCancel()
  }
}
