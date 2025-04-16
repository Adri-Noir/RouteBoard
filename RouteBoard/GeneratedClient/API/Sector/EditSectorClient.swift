// Created with <3 on 15.04.2025.

import Foundation
import OpenAPIURLSession

public struct EditSectorInput {
  let id: String
  let name: String?
  let description: String?
  let locationLatitude: Double?
  let locationLongitude: Double?
  let photos: [Data]?
  let photosToRemove: [String]?

  public init(
    id: String, name: String? = nil, description: String? = nil, locationLatitude: Double? = nil,
    locationLongitude: Double? = nil, photos: [Data]? = nil, photosToRemove: [String]? = nil
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.locationLatitude = locationLatitude
    self.locationLongitude = locationLongitude
    self.photos = photos
    self.photosToRemove = photosToRemove
  }
}

public typealias EditSectorOutput = Components.Schemas.SectorDetailedDto

public class EditSectorClient: AuthenticatedClientProvider {
  public typealias T = EditSectorInput
  public typealias R = EditSectorOutput?

  private var session: URLSession?

  private func createMultipartFormData(data: EditSectorInput, boundary: String) -> Data {
    var formData = Data()

    func appendFormField(name: String, value: String) {
      formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      formData.append(
        "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
      formData.append(value.data(using: .utf8)!)
    }

    // Use a formatter with a locale that uses '.' as the decimal separator
    let numberFormatter = NumberFormatter()
    // Use a locale that uses ',' as the decimal separator, e.g., Croatian
    numberFormatter.locale = Locale(identifier: "hr_HR")
    numberFormatter.numberStyle = .decimal
    // Ensure sufficient decimal places if needed, adjust as necessary
    numberFormatter.maximumFractionDigits = 15  // Or another appropriate precision

    if let locationLatitude = data.locationLatitude,
      let latString = numberFormatter.string(from: NSNumber(value: locationLatitude))
    {
      appendFormField(name: "Location.Latitude", value: latString)
    }
    if let locationLongitude = data.locationLongitude,
      let lonString = numberFormatter.string(from: NSNumber(value: locationLongitude))
    {
      appendFormField(name: "Location.Longitude", value: lonString)
    }

    // Optional fields
    if let name = data.name {
      appendFormField(name: "Name", value: name)
    }
    if let description = data.description {
      appendFormField(name: "Description", value: description)
    }
    if let photosToRemove = data.photosToRemove {
      for photoId in photosToRemove {
        appendFormField(name: "PhotosToRemove", value: photoId)
      }
    }
    if let photos = data.photos {
      for (index, photoData) in photos.enumerated() {
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        formData.append(
          "Content-Disposition: form-data; name=\"Photos\"; filename=\"photo\(index).jpeg\"\r\n"
            .data(using: .utf8)!)
        formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        formData.append(photoData)
      }
    }

    // Close the form
    formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    return formData
  }

  public func call(
    _ data: EditSectorInput,
    _ authData: AuthData,
    _ errorHandler: ((_ message: String) -> Void)? = nil
  ) async -> EditSectorOutput? {
    do {
      let session = CustomClient.createSession()
      self.session = session

      let boundary = UUID().uuidString
      let formData = createMultipartFormData(data: data, boundary: boundary)

      guard let baseURL = try? Servers.Server1.url(),
        let url = URL(string: "/api/Sector/\(data.id)", relativeTo: baseURL)
      else {
        errorHandler?("Failed to create URL")
        return nil
      }

      var request = URLRequest(url: url)
      request.httpMethod = "PUT"
      request.setValue(
        "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      if let token = authData.token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }

      let (responseData, response) = try await session.upload(for: request, from: formData)

      guard let httpResponse = response as? HTTPURLResponse else {
        errorHandler?("Invalid response")
        return nil
      }

      switch httpResponse.statusCode {
      case 200, 201:
        do {
          let decoder = JSONDecoder()
          let sectorDto = try decoder.decode(EditSectorOutput.self, from: responseData)
          return sectorDto
        } catch {
          errorHandler?("Failed to decode successful response: \(error.localizedDescription)")
          return nil
        }
      case 204:
        errorHandler?("Received No Content (204), but expected Sector data.")
        return nil
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
          handleBadRequest(problemDetails, "EditSectorClient", errorHandler)
        } catch {
          handleBadRequestString("Bad request", "EditSectorClient", errorHandler)
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
