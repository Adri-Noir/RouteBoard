// Created with <3 on 20.05.2025.

import SwiftData
import SwiftUI

public struct OfflineCragTabView: View {
  @Query(sort: [SortDescriptor(\DownloadedCrag.name)]) var crags: [DownloadedCrag]

  @EnvironmentObject var navigationManager: NavigationManager
  @Environment(\.modelContext) private var modelContext

  private func deleteCrag(crag: DownloadedCrag) {
    modelContext.delete(crag)
    do {
      try modelContext.save()
    } catch {
      print("Failed to save after deleting crag: \(error)")
    }
  }

  public var body: some View {
    if crags.isEmpty {
      VStack {
        Spacer()
        Text("No crags available.")
          .foregroundColor(Color.newTextColor)
        Spacer()
      }
    } else {
      ScrollView {
        VStack(spacing: 10) {
          ForEach(crags, id: \.id) { crag in
            OfflineCragRowView(
              crag: crag,
              onDelete: { deleteCrag(crag: crag) },
              onNavigate: { navigationManager.pushView(.offlineCrag(cragId: crag.id ?? "")) }
            )
          }
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .background(Color.newBackgroundGray)
    }
  }
}

// MARK: - OfflineCragRowView
struct OfflineCragRowView: View {
  let crag: DownloadedCrag
  let onDelete: () -> Void
  let onNavigate: () -> Void

  var body: some View {
    Button(action: onNavigate) {
      HStack(alignment: .center, spacing: 12) {
        if let urlString = crag.photos.first?.url, let uiImage = UIImage(contentsOfFile: urlString)
        {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(10)
        } else {
          PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
            .frame(width: 60, height: 60)
            .cornerRadius(10)
        }
        VStack(alignment: .leading, spacing: 4) {
          Text(crag.name ?? "Unnamed Crag")
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)
          if let location = crag.locationName {
            Text(location)
              .font(.caption)
              .foregroundColor(.gray)
          }
          Text("Sectors: \(crag.sectors.count)")
            .font(.caption2)
            .foregroundColor(.gray)
        }
        Spacer()
        Button(action: onDelete) {
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
