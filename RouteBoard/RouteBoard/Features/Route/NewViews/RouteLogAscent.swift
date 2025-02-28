// Created with <3 on 25.02.2025.

import GeneratedClient
import SwiftUI

struct RouteLogAscent: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  let route: RouteDetails?
  var onAscentLogged: (() -> Void)?

  let logAscentClient = LogAscentClient()

  @State private var selectedGrade: String = "4a"
  @State private var selectedClimbType: [UserClimbingType] = []
  @State private var rating: Int = 0
  @State private var notes: String = ""
  @State private var isSubmitting: Bool = false
  @State private var scrollPosition: String?
  @State private var ascentDate: Date = Date()
  @State private var showErrorAlert: Bool = false
  @State private var errorMessage: String = ""

  @FocusState private var isNotesFocused: Bool

  private var grades: [String] {
    authViewModel.getGradeSystem().climbingGrades
  }

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  init(route: RouteDetails?, onAscentLogged: (() -> Void)? = nil) {
    self.route = route
    self.onAscentLogged = onAscentLogged
  }

  var body: some View {
    SlideupLayout {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          Text("Log Ascent")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)
            .padding(.horizontal)

          VStack(alignment: .leading, spacing: 10) {
            Text("Ascent Date")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newTextColor)
              .padding(.horizontal)

            DatePicker("", selection: $ascentDate, displayedComponents: [.date])
              .datePickerStyle(.compact)
              .labelsHidden()
              .colorScheme(.light)
              .foregroundStyle(Color.newTextColor)
              .accentColor(Color.newPrimaryColor)
              .padding(.vertical, 8)
              .cornerRadius(10)
              .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
              .padding(.horizontal)
          }

          VStack(alignment: .leading, spacing: 10) {
            Text("Proposed Grade")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newTextColor)
              .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(grades, id: \.self) { grade in
                  Button(action: {
                    withAnimation {
                      selectedGrade = grade == selectedGrade ? "?" : grade
                    }
                  }) {
                    Text(grade)
                      .font(.headline)
                      .padding(.vertical, 8)
                      .padding(.horizontal, 16)
                      .background(selectedGrade == grade ? Color.newPrimaryColor : Color.white)
                      .foregroundColor(selectedGrade == grade ? .white : Color.newTextColor)
                      .cornerRadius(10)
                      .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                  }
                  .id(grade)
                }
              }
              .scrollTargetLayout()
              .padding(.horizontal, 20)
            }
            .scrollPosition(id: $scrollPosition, anchor: .center)
          }

          SectorClimbTypeView(climbTypes: $selectedClimbType)

          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("Rating")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.newTextColor)

              Spacer()

              if rating > 0 {
                Button(action: {
                  withAnimation {
                    rating = 0
                  }
                }) {
                  Text("Clear")
                    .font(.subheadline)
                    .foregroundColor(Color.newPrimaryColor)
                }
              }
            }

            HStack(spacing: 8) {
              ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                  .font(.title2)
                  .foregroundColor(
                    star <= rating ? Color.newSecondaryColor : Color.gray.opacity(0.3)
                  )
                  .onTapGesture {
                    withAnimation {
                      rating = star
                    }
                  }
              }
            }
          }
          .padding(.horizontal, 20)

          VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newTextColor)

            TextEditor(text: $notes)
              .frame(minHeight: 120)
              .padding(10)
              .scrollContentBackground(.hidden)
              .background(Color.white)
              .foregroundColor(Color.newTextColor)
              .cornerRadius(10)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.gray.opacity(0.2), lineWidth: 1)
              )
              .focused($isNotesFocused)
              .onTapBackground(enabled: isNotesFocused) {
                isNotesFocused = false
              }
          }
          .padding(.horizontal, 20)

          Button(action: {
            Task {
              await submitAscent()
            }
          }) {
            HStack {
              Spacer()
              if isSubmitting {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
              } else {
                Text("Submit Ascent")
                  .fontWeight(.bold)
              }
              Spacer()
            }
            .padding()
            .background(Color.newPrimaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
          }
          .padding(.top, 10)
          .disabled(isSubmitting)
        }
        .padding(.top)
      }
      .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
      .task {
        selectedGrade = authViewModel.getGradeSystem().convertGradeToString(route?.grade)
        // Set the scroll position to the selected grade after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          withAnimation {
            scrollPosition = selectedGrade
          }
        }
      }
      .onChange(of: selectedGrade) { _, newGrade in
        withAnimation {
          scrollPosition = newGrade
        }
      }
      .alert("Error", isPresented: $showErrorAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
    }
    .background(Color.newBackgroundGray)
  }

  private func submitAscent() async {
    guard let route = route else {
      errorMessage = "Route information is missing"
      showErrorAlert = true
      return
    }

    isSubmitting = true

    let result = await logAscentClient.call(
      LogAscentInput(
        routeId: route.id,
        ascentDate: ascentDate,
        notes: notes,
        climbTypes: ClimbTypesConverter.convertUserClimbingTypesToComponentsClimbTypes(
          userClimbingTypes: selectedClimbType
        ),
        rockTypes: ClimbTypesConverter.convertUserClimbingTypesToComponentsRockTypes(
          userClimbingTypes: selectedClimbType
        ),
        holdTypes: ClimbTypesConverter.convertUserClimbingTypesToComponentsHoldTypes(
          userClimbingTypes: selectedClimbType
        ),
        proposedGrade: authViewModel.getGradeSystem().convertStringToGrade(selectedGrade),
        rating: Int32(rating)
      ), authViewModel.getAuthData())

    isSubmitting = false

    if result {
      onAscentLogged?()
      dismiss()
    } else {
      errorMessage = "Failed to log ascent"
      showErrorAlert = true
    }
  }
}
