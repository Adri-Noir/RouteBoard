// Created with <3 on 27.03.2025.
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public struct UploadRouteImageInput {
  let routeId: String
  let photo: Data
  let linePhoto: Data
  let combinedPhoto: Data

  public init(routeId: String, photo: Data, linePhoto: Data, combinedPhoto: Data) {
    self.routeId = routeId
    self.photo = photo
    self.linePhoto = linePhoto
    self.combinedPhoto = combinedPhoto
  }
}

public class UploadRouteImageClient: AuthenticatedClientProvider {
  public typealias T = UploadRouteImageInput
  public typealias R = Bool

  private func createMultipartFormData(data: UploadRouteImageInput, boundary: String) -> Data {
    var formData = Data()

    // Add route ID
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append("Content-Disposition: form-data; name=\"RouteId\"\r\n\r\n".data(using: .utf8)!)
    formData.append(data.routeId.data(using: .utf8)!)

    // Add photo
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append(
      "Content-Disposition: form-data; name=\"Photo\"; filename=\"photo.jpeg\"\r\n".data(
        using: .utf8)!)
    formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    formData.append(data.photo)

    // Add line photo
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append(
      "Content-Disposition: form-data; name=\"LinePhoto\"; filename=\"linePhoto.png\"\r\n".data(
        using: .utf8)!)
    formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    formData.append(data.linePhoto)

    // Add combined photo
    formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    formData.append(
      "Content-Disposition: form-data; name=\"CombinedPhoto\"; filename=\"combinedPhoto.jpeg\"\r\n"
        .data(using: .utf8)!)
    formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    formData.append(data.combinedPhoto)

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    return formData
  }

  private var session: URLSession?

  public func call(
    _ data: UploadRouteImageInput,
    _ authData: AuthData,
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
        let url = URL(string: "/addPhoto", relativeTo: baseURL)
      else {
        errorHandler?("Failed to create URL")
        return false
      }

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue(
        "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      // Add authorization if available
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
      case 200, 201, 204:
        return true

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

      case 400:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleBadRequest(problemDetails, "UploadRouteImageClient", errorHandler)
        } catch {
          handleBadRequestString("Bad request", "UploadRouteImageClient", errorHandler)
        }
        return false

      case 404:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleNotFound(problemDetails, errorHandler)
        } catch {
          handleNotFound(nil, errorHandler)
        }
        return false

      default:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          if let detail = problemDetails.detail {
            errorHandler?(detail)
          } else {
            handleUndocumented(errorHandler)
          }
        } catch {
          handleUndocumented(errorHandler)
        }
        return false
      }
    } catch {
      // Log error but don't call errorHandler if it's a cancellation
      if (error as NSError).code != NSURLErrorCancelled {
        errorHandler?(error.localizedDescription)
      }
    }

    return false
  }

  public func cancel() {
    session?.invalidateAndCancel()
    session = nil
  }
}
