// Created with <3 on 04.04.2025.

import GeneratedClient
import SwiftUI

struct CreateRouteView: View {
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var selectedGrade: Components.Schemas.ClimbingGrade? = nil
  @State private var selectedRouteTypes: [Components.Schemas.RouteType] = []
  @State private var length: String = ""
  @State private var isSubmitting: Bool = false
  @State private var errorMessage: String? = nil
  @State private var scrollPosition: String?
  @State private var headerVisibleRatio: CGFloat = 1
  @State private var selectedImages: [UIImage] = []
  @State private var removedPhotoIds: Set<String> = []

  // Route-specific properties
  let sectorId: String
  private var routeDetails: RouteDetails? = nil

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var navigationManager: NavigationManager

  init(routeDetails: RouteDetails) {
    self.routeDetails = routeDetails
    self.sectorId = routeDetails.sectorId
  }

  init(sectorId: String) {
    self.sectorId = sectorId
  }

  private let createRouteClient = CreateRouteClient()
  private let editRouteClient = EditRouteClient()

  private var grades: [String] {
    authViewModel.getGradeSystem().climbingGrades
  }

  private var climbingGradeSystem: ClimbingGrades {
    authViewModel.getGradeSystem()
  }

  private var routeTypes: [Components.Schemas.RouteType] {
    Components.Schemas.RouteType.allCases
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  // Add original values for edit mode
  private var originalName: String { routeDetails?.name ?? "" }
  private var originalDescription: String { routeDetails?.description ?? "" }
  private var originalGrade: Components.Schemas.ClimbingGrade? { routeDetails?.grade }
  private var originalRouteTypes: [Components.Schemas.RouteType] { routeDetails?.routeType ?? [] }
  private var originalLength: String {
    routeDetails?.length != nil ? String(routeDetails!.length!) : ""
  }
  private var originalPhotos: [Components.Schemas.RoutePhotoDto] { routeDetails?.routePhotos ?? [] }

  // Add hasChanges computed property
  private var hasChanges: Bool {
    guard routeDetails != nil else { return true }  // Always true in create mode
    if name != originalName { return true }
    if description != originalDescription { return true }
    if selectedGrade != originalGrade { return true }
    if selectedRouteTypes != originalRouteTypes { return true }
    if length != originalLength { return true }
    if !selectedImages.isEmpty { return true }
    if !removedPhotoIds.isEmpty { return true }
    return false
  }

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollViewWithStickyHeader(
        header: {
          headerView
            .padding(.bottom, 12)
            .background(Color.newBackgroundGray)
        },
        headerOverlay: {
          ZStack {
            HStack {
              backButtonView
              Spacer()
            }
            Text(routeDetails == nil ? "Create Route" : "Edit Route")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(Color.newPrimaryColor)
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .padding(.top, safeAreaInsets.top)
          .padding(.bottom, 12)
          .background(Color.newBackgroundGray)
          .opacity(headerVisibleRatio == 0 ? 1 : 0)
          .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
        },
        headerHeight: safeAreaInsets.top,
        onScroll: { _, headerVisibleRatio in
          self.headerVisibleRatio = headerVisibleRatio
        }
      ) {
        VStack(alignment: .leading, spacing: 20) {
          InputField(
            title: "Route Name",
            text: $name,
            placeholder: "Enter route name here..."
          )
          TextAreaField(
            title: "Description",
            text: $description,
            placeholder: "Enter route description here... (optional)"
          )
          gradeView
          routeTypeView
          InputField(
            title: "Length (meters)",
            text: $length,
            placeholder: "Enter route length... (optional)",
            keyboardType: .numberPad
          )
          if let routeDetails = routeDetails, routeDetails.routePhotos?.count ?? 0 > 0 {
            PhotoPickerField(
              title: "Route Images",
              selectedImages: $selectedImages,
              existingPhotos: routeDetails.routePhotos?.compactMap { $0.combinedPhoto } ?? [],
              removedPhotoIds: $removedPhotoIds,
              disableAddMore: true
            )
          }
          submitButton
        }
        .padding(.bottom, safeAreaInsets.bottom)
      }
      .scrollDismissesKeyboard(.interactively)
      .alert(message: $errorMessage)
      .task {
        if let details = routeDetails {
          name = details.name ?? ""
          description = details.description ?? ""
          selectedGrade = details.grade
          selectedRouteTypes = details.routeType ?? []
          length = details.length != nil ? String(details.length!) : ""
        }
        // Set the scroll position to the selected grade after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          withAnimation {
            scrollPosition = authViewModel.getGradeSystem().convertGradeToString(selectedGrade)
          }
        }
      }
      .onChange(of: selectedGrade) { _, newGrade in
        withAnimation {
          scrollPosition = authViewModel.getGradeSystem().convertGradeToString(newGrade)
        }
      }
    }
    .navigationBarBackButtonHidden()
    .toolbar(.hidden, for: .navigationBar)
    .background(Color.newBackgroundGray)
    .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
  }

  private var backButtonView: some View {
    Button(action: {
      dismiss()
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(Color.newPrimaryColor)
    }
  }

  private var headerView: some View {
    VStack {
      Spacer()
      HStack {
        backButtonView
        Text(routeDetails == nil ? "Create Route" : "Edit Route")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Color.newPrimaryColor)
        Spacer()
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  private var gradeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Grade")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(grades, id: \.self) { gradeString in
            let grade = climbingGradeSystem.convertStringToGrade(gradeString)
            Button(action: {
              withAnimation {
                if gradeString == "?" {
                  selectedGrade = nil
                } else {
                  selectedGrade = selectedGrade == grade ? nil : grade
                }
              }
            }) {
              let isSelected =
                selectedGrade == grade || (gradeString == "?" && selectedGrade == nil)
              Text(gradeString)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.newPrimaryColor : Color.white)
                .foregroundColor(isSelected ? .white : Color.newTextColor)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .id(gradeString)
          }
        }
        .scrollTargetLayout()
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
      .scrollPosition(id: $scrollPosition, anchor: .center)
    }
  }

  private var routeTypeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Route Types")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(routeTypes, id: \.self) { routeType in
            Button(action: {
              withAnimation {
                toggleRouteType(routeType)
              }
            }) {
              Text(RouteTypeConverter.convertToString(routeType) ?? "")
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                  selectedRouteTypes.contains(routeType) ? Color.newPrimaryColor : Color.white
                )
                .foregroundColor(
                  selectedRouteTypes.contains(routeType) ? .white : Color.newTextColor
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
    }
  }

  private func toggleRouteType(_ type: Components.Schemas.RouteType) {
    if let index = selectedRouteTypes.firstIndex(where: { $0 == type }) {
      selectedRouteTypes.remove(at: index)
    } else {
      selectedRouteTypes.append(type)
    }
  }

  private var submitButton: some View {
    Button(action: {
      Task {
        await submitRoute()
      }
    }) {
      HStack {
        Spacer()
        if isSubmitting {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text(routeDetails == nil ? "Create Route" : "Edit Route")
            .fontWeight(.bold)
        }
        Spacer()
      }
      .padding()
      .background(isButtonEnabled ? Color.newPrimaryColor : Color.gray.opacity(0.5))
      .foregroundColor(.white)
      .cornerRadius(10)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .padding(.top, 10)
    .disabled(!isButtonEnabled)
  }

  private var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  // Update isButtonEnabled to require hasChanges in edit mode
  private var isButtonEnabled: Bool {
    !isSubmitting && isFormValid && hasChanges
  }

  private func submitRoute() async {
    isSubmitting = true
    defer { isSubmitting = false }

    // Convert length string to int if provided
    let lengthValue: Int? = {
      guard let length = Int(length.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        return nil
      }
      return length
    }()

    if let details = routeDetails {
      let photosToRemove =
        removedPhotoIds.isEmpty
        ? nil
        : Array(
          details.routePhotos?
            .filter { $0.combinedPhoto != nil && removedPhotoIds.contains($0.combinedPhoto!.id) }
            .compactMap { $0.id } ?? []
        )

      let editCommand = EditRouteCommand(
        name: name == details.name ? nil : name,
        description: description == details.description ? nil : description,
        grade: selectedGrade == details.grade ? nil : selectedGrade,
        routeType: selectedRouteTypes == (details.routeType ?? []) ? nil : selectedRouteTypes,
        length: lengthValue != Int(details.length ?? 0)
          ? (lengthValue != nil ? Int32(lengthValue!) : nil) : nil,
        photosToRemove: photosToRemove
      )
      let result = await editRouteClient.call(
        (details.id, editCommand),
        authViewModel.getAuthData(),
        { message in
          errorMessage = message
        }
      )
      if result != nil {
        navigationManager.pop()
        navigationManager.pushView(.routeDetails(id: result?.id ?? ""))
      }
    } else {
      // Create mode
      let createRouteCommand = CreateRouteCommand(
        name: name,
        description: description.isEmpty ? nil : description,
        grade: selectedGrade,
        routeType: selectedRouteTypes.isEmpty ? nil : selectedRouteTypes,
        length: lengthValue != nil ? Int32(lengthValue!) : nil,
        sectorId: sectorId
      )
      let result = await createRouteClient.call(
        createRouteCommand,
        authViewModel.getAuthData(),
        { message in
          errorMessage = message
        }
      )
      if result != nil {
        navigationManager.pop()
        navigationManager.pushView(.routeDetails(id: result?.id ?? ""))
      }
    }
  }
}

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateRouteView(sectorId: "sample-sector-id")
  }
}
