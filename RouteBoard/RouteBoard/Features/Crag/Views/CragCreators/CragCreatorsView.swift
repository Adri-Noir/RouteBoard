// Created with <3 on 29.05.2025.

import Combine
import GeneratedClient
import SwiftUI

struct CragCreatorsView: View {
  let cragId: String
  let onSuccess: (() -> Void)?
  let onCancel: (() -> Void)?

  @State private var selectedUserIds: Set<String> = []
  @State private var searchQuery: String = ""
  @State private var internalSearchQuery: String = ""
  @State private var searchQueryPublisher = PassthroughSubject<String, Never>()
  @State private var currentPage: Int = 0
  @State private var pageSize: Int = 20

  @State private var allUsers: [Components.Schemas.UserRestrictedDto] = []
  @State private var cragUsers: [Components.Schemas.UserRestrictedDto] = []
  @State private var totalUsers: Int = 0

  @State private var isLoadingAllUsers: Bool = false
  @State private var isLoadingCragUsers: Bool = false
  @State private var isUpdating: Bool = false

  @State private var errorMessage: String? = nil
  @State private var updateErrorMessage: String? = nil

  @EnvironmentObject private var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss

  private let getAllUsersClient = GetAllUsersClient()
  private let getCragCreatorsClient = GetCragCreatorsClient()
  private let updateCragCreatorsClient = UpdateCragCreatorsClient()

  init(cragId: String, onSuccess: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
    self.cragId = cragId
    self.onSuccess = onSuccess
    self.onCancel = onCancel
  }

  var totalPages: Int {
    return max(1, Int(ceil(Double(totalUsers) / Double(pageSize))))
  }

  var hasNextPage: Bool {
    return currentPage < totalPages - 1
  }

  var hasPrevPage: Bool {
    return currentPage > 0
  }

  var isLoading: Bool {
    return isLoadingAllUsers || isLoadingCragUsers
  }

  var hasError: Bool {
    return errorMessage != nil
  }

  var userDisplayData:
    [(user: Components.Schemas.UserRestrictedDto, isSelected: Bool, displayName: String)]
  {
    return allUsers.map { user in
      let isSelected = selectedUserIds.contains(user.id ?? "")
      let displayName =
        user.username
        ?? "\(user.firstName ?? "") \(user.lastName ?? "")".trimmingCharacters(in: .whitespaces)
      return (
        user: user, isSelected: isSelected,
        displayName: displayName.isEmpty ? "Unknown User" : displayName
      )
    }
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      VStack(spacing: 0) {
        if hasError {
          errorView
        } else {
          contentView
        }
      }
    }
    .navigationTitle("Edit Crag Creators")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Cancel") {
          onCancel?()
          dismiss()
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Save") {
          saveChanges()
        }
        .disabled(isUpdating)
      }
    }
    .task {
      await loadInitialData()
    }
    .onReceive(
      searchQueryPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    ) { debouncedSearchQuery in
      searchQuery = debouncedSearchQuery
      currentPage = 0
      Task {
        await loadAllUsers()
      }
    }
    .onChange(of: pageSize) { _, _ in
      currentPage = 0
      Task {
        await loadAllUsers()
      }
    }
  }

  private var errorView: some View {
    VStack(spacing: 16) {
      Text("Failed to load users")
        .font(.headline)
        .foregroundColor(.red)

      if let errorMessage = errorMessage {
        Text(errorMessage)
          .font(.subheadline)
          .foregroundColor(Color.newTextColor)
          .multilineTextAlignment(.center)
      }

      Button("Retry") {
        Task {
          await loadInitialData()
        }
      }
      .padding()
      .background(Color.newPrimaryColor)
      .foregroundColor(.white)
      .cornerRadius(8)
    }
    .padding()
  }

  private var contentView: some View {
    VStack(spacing: 16) {
      searchBar

      userCountHeader

      userList

      if totalPages > 1 {
        paginationControls
      }

      if let updateErrorMessage = updateErrorMessage {
        Text(updateErrorMessage)
          .font(.caption)
          .foregroundColor(.red)
          .padding(.horizontal)
      }

      Spacer()
    }
    .padding()
  }

  private var searchBar: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(Color.newTextColor.opacity(0.6))

      TextField(
        "", text: $internalSearchQuery,
        prompt: Text("Search users...").font(.subheadline).foregroundColor(
          Color.newTextColor.opacity(0.5))
      )
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.never)
      .padding(.horizontal, 12)
      .padding(.vertical, 12)
      .background(Color.white)
      .foregroundColor(Color.newTextColor)
      .cornerRadius(10)
      .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
      .onChange(of: internalSearchQuery) { _, newValue in
        searchQueryPublisher.send(newValue)
      }

      if !internalSearchQuery.isEmpty {
        Button(action: {
          internalSearchQuery = ""
          searchQueryPublisher.send("")
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(Color.newTextColor.opacity(0.6))
        }
      }
    }
  }

  private var userCountHeader: some View {
    HStack {
      Image(systemName: "person.2")
        .foregroundColor(Color.newTextColor.opacity(0.6))

      if isLoading {
        Text("Loading...")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor.opacity(0.6))
      } else {
        Text("\(selectedUserIds.count) of \(allUsers.count) users selected")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor.opacity(0.6))

        if !searchQuery.isEmpty {
          Text("(filtered by \"\(searchQuery)\")")
            .font(.caption)
            .foregroundColor(Color.newTextColor.opacity(0.6))
        }
      }

      Spacer()
    }
  }

  private var userList: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        if isLoading {
          ForEach(0..<5, id: \.self) { _ in
            userRowSkeleton
          }
        } else if userDisplayData.isEmpty {
          emptyState
        } else {
          ForEach(userDisplayData, id: \.user.id) { userData in
            userRow(userData: userData)
          }
        }
      }
      .padding(.vertical, 8)
    }
    .frame(maxHeight: 400)
  }

  private var userRowSkeleton: some View {
    HStack(spacing: 12) {
      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 20, height: 20)
        .cornerRadius(4)

      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(height: 16)
        .cornerRadius(4)

      Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "person.2.slash")
        .font(.system(size: 48))
        .foregroundColor(Color.newTextColor.opacity(0.3))

      Text("No users found")
        .font(.subheadline)
        .foregroundColor(Color.newTextColor.opacity(0.6))
    }
    .padding(.vertical, 40)
  }

  private func userRow(
    userData: (user: Components.Schemas.UserRestrictedDto, isSelected: Bool, displayName: String)
  ) -> some View {
    HStack(spacing: 12) {
      Button(action: {
        toggleUser(userId: userData.user.id ?? "")
      }) {
        Image(systemName: userData.isSelected ? "checkmark.square.fill" : "square")
          .foregroundColor(
            userData.isSelected ? Color.newPrimaryColor : Color.newTextColor.opacity(0.6)
          )
          .font(.system(size: 20))
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(userData.displayName)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(Color.newTextColor)

        if let username = userData.user.username, username != userData.displayName {
          Text("@\(username)")
            .font(.caption)
            .foregroundColor(Color.newTextColor.opacity(0.6))
        }
      }

      Spacer()
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
    .onTapGesture {
      toggleUser(userId: userData.user.id ?? "")
    }
  }

  private var paginationControls: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Page \(currentPage + 1) of \(totalPages) (\(totalUsers) total users)")
          .font(.caption)
          .foregroundColor(Color.newTextColor.opacity(0.6))

        Spacer()

        Picker("Page Size", selection: $pageSize) {
          Text("10").tag(10)
          Text("20").tag(20)
          Text("50").tag(50)
          Text("100").tag(100)
        }
        .pickerStyle(MenuPickerStyle())
        .disabled(isLoading)
      }

      HStack {
        Button("Previous") {
          if hasPrevPage {
            currentPage -= 1
            Task {
              await loadAllUsers()
            }
          }
        }
        .disabled(!hasPrevPage || isLoading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(hasPrevPage && !isLoading ? Color.newPrimaryColor : Color.gray.opacity(0.3))
        .foregroundColor(.white)
        .cornerRadius(8)

        Spacer()

        Button("Next") {
          if hasNextPage {
            currentPage += 1
            Task {
              await loadAllUsers()
            }
          }
        }
        .disabled(!hasNextPage || isLoading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(hasNextPage && !isLoading ? Color.newPrimaryColor : Color.gray.opacity(0.3))
        .foregroundColor(.white)
        .cornerRadius(8)
      }
    }
  }

  private func loadInitialData() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await loadCragUsers()
      }
      group.addTask {
        await loadAllUsers()
      }
    }
  }

  private func loadAllUsers() async {
    isLoadingAllUsers = true
    defer { isLoadingAllUsers = false }

    let input = GetAllUsersInput(
      page: currentPage,
      pageSize: pageSize,
      search: searchQuery.isEmpty ? nil : searchQuery
    )

    guard
      let response = await getAllUsersClient.call(
        input,
        authViewModel.getAuthData(),
        { errorMessage = $0 }
      )
    else {
      return
    }

    await MainActor.run {
      allUsers = response.users ?? []
      totalUsers = Int(response.totalCount ?? 0)
      errorMessage = nil
    }
  }

  private func loadCragUsers() async {
    isLoadingCragUsers = true
    defer { isLoadingCragUsers = false }

    let input = GetCragCreatorsInput(id: cragId)

    guard
      let users = await getCragCreatorsClient.call(
        input,
        authViewModel.getAuthData(),
        { errorMessage = $0 }
      )
    else {
      return
    }

    await MainActor.run {
      cragUsers = users
      selectedUserIds = Set(users.compactMap { $0.id })
      errorMessage = nil
    }
  }

  private func toggleUser(userId: String) {
    if selectedUserIds.contains(userId) {
      selectedUserIds.remove(userId)
    } else {
      selectedUserIds.insert(userId)
    }
  }

  private func saveChanges() {
    Task {
      isUpdating = true
      updateErrorMessage = nil
      defer { isUpdating = false }

      let input = UpdateCragCreatorsInput(
        cragId: cragId,
        userIds: Array(selectedUserIds)
      )

      guard
        await updateCragCreatorsClient.call(
          input,
          authViewModel.getAuthData(),
          { updateErrorMessage = $0 }
        ) != nil
      else {
        return
      }

      await MainActor.run {
        onSuccess?()
        dismiss()
      }
    }
  }
}

#Preview {
  AuthInjectionMock {
    CragCreatorsView(cragId: "0195edd5-0b70-762c-8e61-f73e73563029")
  }
}
