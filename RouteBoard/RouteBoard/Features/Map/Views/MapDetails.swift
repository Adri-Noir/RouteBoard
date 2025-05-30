// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

// MARK: - Detail Cards
// Bottom detail card for crag
struct CragDetailCard: View {
  let crag: Components.Schemas.GlobeResponseDto
  let onClose: () -> Void
  let mapViewModel: MapViewModel

  @State private var isLoadingSectors = false

  private var sectors: [Components.Schemas.GlobeSectorResponseDto] {
    mapViewModel.sectors
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Card container with backdrop blur effect
      VStack(alignment: .leading, spacing: 0) {
        // Header section
        VStack(alignment: .leading, spacing: 12) {
          // Title and close button row
          HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
              // Crag name with link styling
              if let cragId = crag.id {
                CragLink(cragId: cragId) {
                  Text(crag.name ?? "Unnamed Crag")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.newTextColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                }
                .buttonStyle(PlainButtonStyle())
              } else {
                Text(crag.name ?? "Unnamed Crag")
                  .font(.system(size: 18, weight: .semibold))
                  .foregroundColor(Color.newTextColor)
                  .lineLimit(2)
              }

              // Location coordinates
              if let location = crag.location {
                HStack(spacing: 4) {
                  Image(systemName: "mappin")
                    .font(.system(size: 12))
                    .foregroundColor(Color.newTextColor.opacity(0.6))

                  Text(
                    "\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))"
                  )
                  .font(.system(size: 12))
                  .foregroundColor(Color.newTextColor.opacity(0.6))
                }
              }
            }

            Spacer()

            // Close button
            Button(action: onClose) {
              Image(systemName: "xmark")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.newTextColor.opacity(0.6))
                .frame(width: 32, height: 32)
                .background(Color.newTextColor.opacity(0.1))
                .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)

        // Content section
        VStack(alignment: .leading, spacing: 16) {
          // Crag image
          if let imageUrl = crag.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
              switch phase {
              case .success(let image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(height: 128)
                  .clipped()
                  .cornerRadius(8)
              case .failure:
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.newTextColor.opacity(0.1))
                  .frame(height: 128)
                  .overlay(
                    Image(systemName: "photo")
                      .font(.system(size: 24))
                      .foregroundColor(Color.newTextColor.opacity(0.4))
                  )
              default:
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.newTextColor.opacity(0.1))
                  .frame(height: 128)
                  .overlay(
                    ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
                  )
              }
            }
            .padding(.horizontal, 16)
          }

          // Sectors section
          VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
              Image(systemName: "grid.circle")
                .font(.system(size: 16))
                .foregroundColor(Color.newTextColor.opacity(0.6))

              if isLoadingSectors {
                Text("Loading sectors...")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(Color.newTextColor.opacity(0.6))
              } else if sectors.isEmpty {
                Text("No sectors available")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(Color.newTextColor.opacity(0.6))
              } else {
                Text("\(sectors.count) \(sectors.count == 1 ? "Sector" : "Sectors")")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(Color.newTextColor)
              }
            }
            .padding(.horizontal, 16)

            // Horizontal scrollable sector badges
            if !sectors.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(sectors, id: \.id) { sector in
                    if let sectorId = sector.id {
                      SectorLink(sectorId: sectorId) {
                        Text(sector.name ?? "Unnamed")
                          .font(.system(size: 12, weight: .medium))
                          .foregroundColor(Color.white)
                          .padding(.horizontal, 12)
                          .padding(.vertical, 6)
                          .background(Color.newPrimaryColor)
                          .cornerRadius(16)
                          .lineLimit(1)
                      }
                      .buttonStyle(PlainButtonStyle())
                    }
                  }
                }
                .padding(.horizontal, 16)
              }
            }
          }

          // Action buttons section
          VStack(spacing: 0) {
            Divider()
              .background(Color.newTextColor.opacity(0.1))

            HStack(spacing: 12) {
              if let cragId = crag.id {
                CragLink(cragId: cragId) {
                  HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                      .font(.system(size: 12, weight: .medium))
                    Text("View Details")
                      .font(.system(size: 14, weight: .medium))
                  }
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 12)
                  .background(Color.newPrimaryColor)
                  .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
          }
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.newBackgroundGray)
          .shadow(color: Color.newTextColor.opacity(0.1), radius: 8, x: 0, y: 4)
          .environment(\.colorScheme, .light)
      )
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.bottom, 20)
    .onAppear {
      // Load sectors when card appears
      if sectors.isEmpty {
        Task {
          isLoadingSectors = true
          await mapViewModel.selectCrag(crag)
          isLoadingSectors = false
        }
      }
    }
  }
}
