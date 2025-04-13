// Created with <3 on 31.03.2025.

import Foundation  // Add Foundation for Data
import OpenAPIURLSession

// Define the input struct based on the multipart/form-data schema
public struct CreateCragInput {
  let name: String
  let description: String?
  let photos: [Data]?  // Array of photos, optional

  public init(name: String, description: String? = nil, photos: [Data]? = nil) {
    self.name = name
    self.description = description
    self.photos = photos
  }
}

// Output type remains the same
public typealias CreateCragOutput = Components.Schemas.CragDetailedDto

// Ensure conformance to the correct protocol
public class CreateCragClient: AuthenticatedClientProvider {
  // Update type aliases
  public typealias T = CreateCragInput
  public typealias R = CreateCragOutput?

  private var session: URLSession?  // Add session property

  // Helper function to create multipart form data
  private func createMultipartFormData(data: CreateCragInput, boundary: String) -> Data {
    var formData = Data()

    // Helper to append form fields
    func appendFormField(name: String, value: String) {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
      formData.append(value.data(using: .utf8)!)
    }

    // Append required field
    appendFormField(name: "Name", value: data.name)

    // Append optional fields
    if let description = data.description {
      appendFormField(name: "Description", value: description)
    }

    // Append photos if provided
    if let photos = data.photos {
      for (index, photoData) in photos.enumerated() {
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        // Use the field name "Photos" as specified in the schema
        formData.append(
          "Content-Disposition: form-data; name=\"Photos\"; filename=\"photo\(index).jpeg\"\r\n"
            .data(using: .utf8)!)
        formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)  // Assuming JPEG
        formData.append(photoData)
      }
    }

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    return formData
  }

  // Updated call method using manual URLSession request
  public func call(
    _ data: CreateCragInput,  // Use the new input type
    _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> CreateCragOutput? {  // Return type remains the same
    do {
      // Create URLSession using CustomClient
      let session = CustomClient.createSession()
      self.session = session

      // Create boundary and multipart form data
      let boundary = UUID().uuidString
      let formData = createMultipartFormData(data: data, boundary: boundary)

      // Create URL and request
      // IMPORTANT: Use the correct path for creating a crag, e.g., "/api/Crag"
      guard let baseURL = try? Servers.Server1.url(),
        let url = URL(string: "/api/Crag", relativeTo: baseURL)
      else {
        errorHandler?("Failed to create URL")
        return nil
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
        return nil
      }

      // Handle response codes
      switch httpResponse.statusCode {
      case 200, 201:  // Success
        do {
          let decoder = JSONDecoder()
          let cragDto = try decoder.decode(CreateCragOutput.self, from: responseData)
          return cragDto
        } catch {
          errorHandler?("Failed to decode successful response: \(error.localizedDescription)")
          return nil
        }

      case 204:  // No Content
        errorHandler?("Received No Content (204), but expected Crag data.")
        return nil

      case 401:  // Unauthorized
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          await handleUnauthorize(problemDetails, authData, errorHandler)
        } catch {
          await handleUnauthorize(nil, authData, errorHandler)
        }
        return nil

      case 400:  // Bad Request
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleBadRequest(problemDetails, "CreateCragClient", errorHandler)
        } catch {
          handleBadRequestString("Bad request", "CreateCragClient", errorHandler)
        }
        return nil

      case 404:  // Not Found - Might not be applicable for create, but included for completeness
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleNotFound(problemDetails, errorHandler)
        } catch {
          handleNotFound(nil, errorHandler)
        }
        return nil

      default:  // Undocumented or other errors
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
        return nil
      }
    } catch {
      // Log error but don't call errorHandler if it's a cancellation
      if (error as NSError).code != NSURLErrorCancelled {
        errorHandler?(error.localizedDescription)
      }
    }

    return nil
  }

  // Update cancel method
  public func cancel() {
    session?.invalidateAndCancel()
    session = nil
  }
}
