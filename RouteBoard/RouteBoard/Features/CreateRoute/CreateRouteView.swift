// Created with <3 on 04.04.2025.

import GeneratedClient
import SwiftUI

struct CreateRouteView: View {
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var selectedGrade: String? = nil
  @State private var selectedRouteTypes: [Components.Schemas.RouteType] = []
  @State private var length: String = ""
  @State private var isSubmitting: Bool = false
  @State private var errorMessage: String? = nil
  @State private var scrollPosition: String?

  // Route-specific properties
  let sectorId: String

  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var navigationManager: NavigationManager

  private let createRouteClient = CreateRouteClient()

  private var grades: [String] {
    authViewModel.getGradeSystem().climbingGrades
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

  var body: some View {
    ApplyBackgroundColor(backgroundColor: Color.newBackgroundGray) {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          headerView

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

          submitButton
        }
        .padding(.top)
      }
      .navigationBarBackButtonHidden()
      .toolbar(.hidden, for: .navigationBar)
      .padding(.top, 2)
      .background(Color.newBackgroundGray)
      .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
      .scrollDismissesKeyboard(.interactively)
      .alert(message: $errorMessage)
      .task {
        // Set the scroll position to the selected grade after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          withAnimation {
            scrollPosition = selectedGrade ?? "?"
          }
        }
      }
      .onChange(of: selectedGrade) { _, newGrade in
        withAnimation {
          scrollPosition = newGrade ?? "?"
        }
      }
    }
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
    HStack {
      backButtonView
      Text("Create Route")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)
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
          ForEach(grades, id: \.self) { grade in
            Button(action: {
              withAnimation {
                if grade == "?" {
                  selectedGrade = nil
                } else {
                  selectedGrade = grade == selectedGrade ? nil : grade
                }
              }
            }) {
              let isSelected = selectedGrade == grade || (grade == "?" && selectedGrade == nil)
              Text(grade)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.newPrimaryColor : Color.white)
                .foregroundColor(isSelected ? .white : Color.newTextColor)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .id(grade)
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
          Text("Create Route")
            .fontWeight(.bold)
        }
        Spacer()
      }
      .padding()
      .background(isFormValid ? Color.newPrimaryColor : Color.gray.opacity(0.5))
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

  private var isButtonEnabled: Bool {
    !isSubmitting && isFormValid
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

    let createRouteCommand = CreateRouteCommand(
      name: name,
      description: description.isEmpty ? nil : description,
      grade: selectedGrade == nil
        ? nil : authViewModel.getGradeSystem().convertStringToGrade(selectedGrade!),
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

// MARK: - Preview
#Preview {
  AuthInjectionMock {
    CreateRouteView(sectorId: "sample-sector-id")
  }
}
