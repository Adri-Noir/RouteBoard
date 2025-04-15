// Created with <3 on 22.03.2025.

import SwiftUI

struct SectorPickerView: View {
  let sectors: [SectorDetailedDto]
  let selectedSector: SectorDetailedDto?

  @Binding var selectedSectorId: String?
  @Binding var isOpen: Bool

  @State private var isOptionsOpen: Bool = false

  @EnvironmentObject var navigationManager: NavigationManager

  var body: some View {
    if sectors.count == 0 {
      Text(selectedSector?.name ?? "Select Sector")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
    } else {
      HStack {
        Button {
          isOpen.toggle()
        } label: {
          HStack(spacing: 4) {
            Text(
              selectedSectorId == nil ? "All Sectors" : (selectedSector?.name ?? "Select Sector")
            )
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)

            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(Color.newTextColor)
          }
          .foregroundColor(Color.newTextColor)
        }
        .popover(
          isPresented: $isOpen,
          attachmentAnchor: .point(.bottom),
          arrowEdge: .top
        ) {
          SectorPickerPopoverContent(
            sectors: sectors,
            selectedSectorId: $selectedSectorId,
            isOpen: $isOpen
          )
        }

        Spacer()

        if let selectedSectorId = selectedSectorId, let selectedSector = selectedSector {
          Button {
            isOptionsOpen.toggle()
          } label: {
            Image(systemName: "ellipsis.circle")
              .font(.title3)
              .foregroundColor(Color.newPrimaryColor)
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())
          }
          .popover(
            isPresented: $isOptionsOpen,
            attachmentAnchor: .point(.bottom),
            arrowEdge: .top
          ) {
            VStack {
              Button {
                navigationManager.pushView(.createRoute(sectorId: selectedSectorId))
              } label: {
                Label("Add Route", systemImage: "plus")
              }

              Button {
                navigationManager.pushView(.editSector(sectorDetails: selectedSector))
              } label: {
                Label("Edit Sector", systemImage: "pencil")
              }
            }
          }
        }
      }
    }
  }
}

// Sector Picker Popover Content
struct SectorPickerPopoverContent: View {
  let sectors: [SectorDetailedDto]
  @Binding var selectedSectorId: String?
  @Binding var isOpen: Bool

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 8) {
        // All Sectors option
        Button(action: {
          withAnimation {
            selectedSectorId = nil
          }
          isOpen = false
        }) {
          HStack {
            Text("All Sectors")
            Spacer()
            if selectedSectorId == nil {
              Image(systemName: "checkmark")
            }
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 12)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(Color.newTextColor)

        Divider()

        // Individual sectors
        ForEach(sectors, id: \.id) { sector in
          Button(action: {
            withAnimation {
              selectedSectorId = sector.id
            }
            isOpen = false
          }) {
            HStack {
              Text(sector.name ?? "Unnamed Sector")
              Spacer()
              if selectedSectorId == sector.id {
                Image(systemName: "checkmark")
              }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
          }
          .buttonStyle(PlainButtonStyle())
          .foregroundColor(Color.newTextColor)

          if sector.id != sectors.last?.id {
            Divider()
          }
        }
      }
      .padding(.vertical, 12)
      .frame(width: 200)
    }
    .preferredColorScheme(.light)
    .presentationCompactAdaptation(.popover)
  }
}
