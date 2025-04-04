// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

// MARK: - Detail Cards
// Bottom detail card for crag
struct CragDetailCard: View {
  let crag: Components.Schemas.GlobeResponseDto
  let onClose: () -> Void

  var body: some View {
    DetailCardContainer(title: crag.name ?? "Unknown Crag", onClose: onClose) {
      HStack(spacing: 10) {
        // Crag image
        CragImage(imageUrl: crag.imageUrl)

        // View details button
        if let cragId = crag.id {
          CragLink(cragId: cragId) {
            DetailLinkButton(text: "View Details", color: .blue)
          }
          .buttonStyle(BorderlessButtonStyle())
        }
      }
    }
  }
}

struct CragImage: View {
  let imageUrl: String?

  var body: some View {
    if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
      AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          Image(systemName: "photo")
            .foregroundColor(.gray)
            .padding(4)
            .background(Color.gray.opacity(0.2))
        default:
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
        }
      }
      .frame(width: 60, height: 60)
      .cornerRadius(6)
      .clipped()
    } else {
      Image(systemName: "mountain.2.fill")
        .font(.system(size: 30))
        .foregroundColor(.orange)
        .frame(width: 60, height: 60)
        .background(Color.orange.opacity(0.2))
        .cornerRadius(6)
    }
  }
}

// Bottom detail card for sector
struct SectorDetailCard: View {
  let sector: Components.Schemas.GlobeSectorResponseDto
  let onClose: () -> Void

  var body: some View {
    DetailCardContainer(title: sector.name ?? "Unknown Sector", onClose: onClose) {
      HStack(spacing: 10) {
        // Sector image
        SectorImage(imageUrl: sector.imageUrl)

        // View details button
        if let sectorId = sector.id {
          SectorLink(sectorId: sectorId) {
            DetailLinkButton(text: "View Details", color: .green)
          }
          .buttonStyle(BorderlessButtonStyle())
        }
      }
    }
  }
}

struct SectorImage: View {
  let imageUrl: String?

  var body: some View {
    if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
      AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          Image(systemName: "photo")
            .foregroundColor(.gray)
            .padding(4)
            .background(Color.gray.opacity(0.2))
        default:
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
        }
      }
      .frame(width: 60, height: 60)
      .cornerRadius(6)
      .clipped()
    } else {
      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 30))
        .foregroundColor(.green)
        .frame(width: 60, height: 60)
        .background(Color.green.opacity(0.2))
        .cornerRadius(6)
    }
  }
}

struct DetailCardContainer<Content: View>: View {
  let title: String
  let onClose: () -> Void
  let content: Content

  init(title: String, onClose: @escaping () -> Void, @ViewBuilder content: () -> Content) {
    self.title = title
    self.onClose = onClose
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header with close button
      HStack {
        Text(title)
          .font(.subheadline)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)
          .lineLimit(1)

        Spacer()

        Button(action: onClose) {
          Image(systemName: "xmark.circle.fill")
            .font(.body)
            .foregroundColor(.gray)
        }
        .buttonStyle(BorderlessButtonStyle())
      }

      content
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 3)
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
  }
}

struct DetailLinkButton: View {
  let text: String
  let color: Color

  var body: some View {
    HStack {
      Text(text)
        .font(.caption)
        .fontWeight(.medium)

      Image(systemName: "arrow.right")
        .font(.caption)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(color)
    .foregroundColor(.white)
    .cornerRadius(6)
  }
}
