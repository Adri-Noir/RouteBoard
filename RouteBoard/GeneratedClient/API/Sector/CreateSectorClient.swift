// Created with <3 on 03.04.2025.

import Foundation
import OpenAPIURLSession  // Keep URLSession import

// Removed OpenAPIRuntime import as we're not using the generated client directly

// Define the input struct based on the OpenAPI schema
public struct CreateSectorInput {
  let name: String
  let description: String?
  let latitude: Double
  let longitude: Double
  let cragId: String?  // Assuming CragId is optional based on schema (not in required list)
  let photos: [Data]?  // Array of photos, optional

  public init(
    name: String, description: String? = nil, latitude: Double, longitude: Double,
    cragId: String? = nil, photos: [Data]? = nil
  ) {
    self.name = name
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.cragId = cragId
    self.photos = photos
  }
}

// Define the output type
public typealias CreateSectorOutput = Components.Schemas.SectorDetailedDto

// Ensure conformance to the correct protocol (assuming AuthenticatedClientProvider)
public class CreateSectorClient: AuthenticatedClientProvider {
  // Update type aliases to use the new Input struct
  public typealias T = CreateSectorInput
  public typealias R = CreateSectorOutput?

  private var session: URLSession?  // Add session property

  // Helper function to create multipart form data
  private func createMultipartFormData(data: CreateSectorInput, boundary: String) -> Data {
    var formData = Data()

    // Helper to append form fields
    func appendFormField(name: String, value: String) {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
      formData.append(value.data(using: .utf8)!)
    }

    // Append required fields
    appendFormField(name: "Name", value: data.name)

    // Use a formatter with a locale that uses ',' as the decimal separator
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "hr_HR")  // Croatian locale
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 15  // Or another appropriate precision

    if let latString = numberFormatter.string(from: NSNumber(value: data.latitude)) {
      appendFormField(name: "Location.Latitude", value: latString)
    }
    if let lonString = numberFormatter.string(from: NSNumber(value: data.longitude)) {
      appendFormField(name: "Location.Longitude", value: lonString)
    }

    // Append optional fields
    if let description = data.description {
      appendFormField(name: "Description", value: description)
    }
    if let cragId = data.cragId {
      appendFormField(name: "CragId", value: cragId)
    }

    // Append photos if provided
    if let photos = data.photos {
      for (index, photoData) in photos.enumerated() {
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        // Use the field name "Photos" as specified in the schema
        formData.append(
          "Content-Disposition: form-data; name=\"Photos\"; filename=\"photo\(index).jpeg\"\r\n"
            .data(using: .utf8)!)
        formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)  // Assuming JPEG, adjust if needed
        formData.append(photoData)
      }
    }

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    return formData
  }

  // Updated call method using manual URLSession request
  public func call(
    _ data: CreateSectorInput,  // Use the new input type
    _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> CreateSectorOutput? {  // Return type remains the same
    do {
      // Create URLSession using CustomClient
      let session = CustomClient.createSession()
      self.session = session

      // Create boundary and multipart form data
      let boundary = UUID().uuidString
      let formData = createMultipartFormData(data: data, boundary: boundary)

      // Create URL and request
      // IMPORTANT: Adjust the path "/api/Sector" if it's different in your API specification
      guard let baseURL = try? Servers.Server1.url(),
        let url = URL(string: "/api/Sector", relativeTo: baseURL)
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

      // Handle response codes similar to UploadCragPhotosClient
      switch httpResponse.statusCode {
      case 200, 201:  // Assuming 200 or 201 means success and returns SectorDetailedDto
        do {
          let decoder = JSONDecoder()
          // Assuming the success response body contains the SectorDetailedDto JSON
          let sectorDto = try decoder.decode(CreateSectorOutput.self, from: responseData)
          return sectorDto
        } catch {
          errorHandler?("Failed to decode successful response: \(error.localizedDescription)")
          return nil
        }

      case 204:  // Handle No Content response if applicable
        errorHandler?("Received No Content (204), but expected Sector data.")  // Or handle as success if appropriate
        return nil  // Or return a default/empty state if needed

      case 401:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          await handleUnauthorize(problemDetails, authData, errorHandler)
        } catch {
          await handleUnauthorize(nil, authData, errorHandler)
        }
        return nil

      case 400:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleBadRequest(problemDetails, "CreateSectorClient", errorHandler)
        } catch {
          handleBadRequestString("Bad request", "CreateSectorClient", errorHandler)
        }
        return nil

      case 404:
        do {
          let decoder = JSONDecoder()
          let problemDetails = try decoder.decode(
            Components.Schemas.CustomProblemDetailsResponse.self, from: responseData)
          handleNotFound(problemDetails, errorHandler)
        } catch {
          handleNotFound(nil, errorHandler)
        }
        return nil

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

  // Add cancel method similar to UploadCragPhotosClient
  public func cancel() {
    session?.invalidateAndCancel()
    session = nil
  }
}
