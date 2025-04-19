// Created with <3 on 22.03.2025.

import GeneratedClient
import SwiftUI

struct SectorPickerView: View {
  let sectors: [SectorDetailedDto]
  let selectedSector: SectorDetailedDto?
  @Binding var selectedSectorId: String?
  let refetch: () -> Void

  @State private var isOpen: Bool = false
  @State private var isOptionsOpen: Bool = false
  @State private var isDeletingSector: Bool = false
  @State private var showDeleteConfirmation: Bool = false
  @State private var deleteError: String? = nil

  @EnvironmentObject var navigationManager: NavigationManager
  @EnvironmentObject var authViewModel: AuthViewModel

  private let deleteSectorClient = DeleteSectorClient()

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
            Image(systemName: "ellipsis")
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
            VStack(alignment: .leading, spacing: 12) {
              Button {
                isOptionsOpen = false
                navigationManager.pushView(.createRoute(sectorId: selectedSectorId))
              } label: {
                HStack {
                  Image(systemName: "plus")
                  Text("Add Route")
                  Spacer()
                }
                .padding(.horizontal, 12)
                .foregroundColor(Color.newTextColor)
              }

              Divider()

              Button {
                isOptionsOpen = false
                navigationManager.pushView(.editSector(sectorDetails: selectedSector))
              } label: {
                HStack {
                  Image(systemName: "pencil")
                  Text("Edit Sector")
                  Spacer()
                }
                .padding(.horizontal, 12)
                .foregroundColor(Color.newTextColor)
              }

              if authViewModel.isCreator {
                Divider()

                Button {
                  isOptionsOpen = false
                  showDeleteConfirmation = true
                } label: {
                  HStack {
                    Image(systemName: "trash")
                    Text("Delete Sector")
                    Spacer()
                  }
                  .padding(.horizontal, 12)
                  .foregroundColor(Color.red)
                }
              }
            }
            .padding(.vertical, 12)
            .frame(width: 200)
            .preferredColorScheme(.light)
            .presentationCompactAdaptation(.popover)
          }
          .alert(
            isPresented: Binding<Bool>(
              get: { showDeleteConfirmation || deleteError != nil },
              set: { newValue in
                if !newValue {
                  showDeleteConfirmation = false
                  deleteError = nil
                }
              })
          ) {
            if let error = deleteError {
              return Alert(
                title: Text("Delete Failed"),
                message: Text(error),
                dismissButton: .default(Text("OK")) {
                  deleteError = nil
                }
              )
            } else {
              return Alert(
                title: Text("Delete Sector"),
                message: Text(
                  "Are you sure you want to delete this sector? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                  Task {
                    await deleteSector()
                  }
                },
                secondaryButton: .cancel {
                  showDeleteConfirmation = false
                }
              )
            }
          }
        }
      }
    }
  }

  private func deleteSector() async {
    guard let sectorId = selectedSector?.id else { return }
    isDeletingSector = true
    let success = await deleteSectorClient.call(
      DeleteSectorInput(id: sectorId),
      authViewModel.getAuthData()
    ) { errorMsg in
      DispatchQueue.main.async {
        deleteError = errorMsg
      }
    }
    isDeletingSector = false
    if success {
      selectedSectorId = nil
      isOpen = false
      refetch()
    } else if deleteError == nil {
      deleteError = "Failed to delete sector. Please try again."
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
