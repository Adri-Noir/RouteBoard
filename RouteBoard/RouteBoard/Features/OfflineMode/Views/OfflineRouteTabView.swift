// Created with <3 on 20.05.2025.

import SwiftData
import SwiftUI

public struct OfflineRoutesTabView: View {
  @Query(sort: [SortDescriptor(\DownloadedRoute.name)]) var routes: [DownloadedRoute]

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var navigationManager: NavigationManager

  private func deleteRoute(route: DownloadedRoute) {
    // Cascade delete associated photos first
    for photo in route.photos {
      modelContext.delete(photo)
    }
    // Delete the route itself
    modelContext.delete(route)
    do {
      try modelContext.save()
    } catch {
      print("Failed to save after deleting route and photos: \(error)")
    }
  }

  public var body: some View {
    if routes.isEmpty {
      VStack {
        Spacer()
        Text("No routes available.")
          .foregroundColor(Color.newTextColor)
        Spacer()
      }
    } else {
      ScrollView {
        VStack(spacing: 10) {
          ForEach(routes, id: \.id) { route in
            Button(action: {
              navigationManager.pushView(.offlineRoute(routeId: route.id ?? ""))
            }) {
              HStack(alignment: .center, spacing: 12) {
                // Route image or placeholder
                if let photoUrl: String = route.photos.first?.combinedImageUrl?.absoluteString,
                  let url = URL(string: photoUrl),
                  url.isFileURL,
                  let uiImage = UIImage(contentsOfFile: url.path)
                {
                  Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(10)
                } else {
                  PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 4) {
                  Text(route.name ?? "Unnamed Route")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(Color.newTextColor)
                  if let grade = route.grade {
                    Text("Grade: \(authViewModel.getGradeSystem().convertGradeToString(grade))")
                      .font(.caption)
                      .foregroundColor(.gray)
                  }
                  if let cragName = route.cragName {
                    Text("Crag: \(cragName)")
                      .font(.caption)
                      .foregroundColor(.gray)
                  }
                  if let length = route.length {
                    Text("Length: \(length)m")
                      .font(.caption2)
                      .foregroundColor(.gray)
                  }
                }
                Spacer()
                Button(action: {
                  deleteRoute(route: route)
                }) {
                  Image(systemName: "trash")
                    .foregroundColor(.red)
                }
                Image(systemName: "chevron.right")
                  .foregroundColor(.gray)
              }
              .padding(10)
              .background(Color.white)
              .cornerRadius(10)
              .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
          }
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .background(Color.newBackgroundGray)
    }
  }
}
