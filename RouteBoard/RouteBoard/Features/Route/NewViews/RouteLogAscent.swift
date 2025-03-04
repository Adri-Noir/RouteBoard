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
  @State private var errorMessage: String? = nil
  @State private var selectedAscentType: Components.Schemas.AscentType = .Redpoint
  @State private var attemptsCount: Int? = nil
  @FocusState private var isAttemptsCountFocused: Bool
  @FocusState private var isNotesFocused: Bool

  private var grades: [String] {
    authViewModel.getGradeSystem().climbingGrades
  }

  private var ascentRequiresAttemptCount: Bool {
    selectedAscentType == .Redpoint || selectedAscentType == .Aid
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
          headerView
          datePickerView
          ascentTypeView

          if ascentRequiresAttemptCount {
            attemptsCountView
          }

          gradeView
          SectorClimbTypeView(climbTypes: $selectedClimbType)
          ratingView
          notesView
          submitButton
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
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Done") {
            isAttemptsCountFocused = false
            isNotesFocused = false
          }
          .foregroundColor(Color.newPrimaryColor)
        }
      }
      .onTapGesture {
        isAttemptsCountFocused = false
        isNotesFocused = false
      }
      .alert(message: $errorMessage)
    }
    .background(Color.newBackgroundGray)
  }

  // MARK: - Subviews

  private var headerView: some View {
    Text("Log Ascent")
      .font(.largeTitle)
      .fontWeight(.bold)
      .foregroundColor(Color.newTextColor)
      .padding(.horizontal)
  }

  private var datePickerView: some View {
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
  }

  private var ascentTypeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Ascent Type")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(Components.Schemas.AscentType.allCases, id: \.self) { ascentType in
            Button(action: {
              withAnimation {
                selectedAscentType = ascentType
                if !ascentRequiresAttemptCount {
                  attemptsCount = nil
                }
              }
            }) {
              Text(ascentType.rawValue)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                  selectedAscentType == ascentType ? Color.newPrimaryColor : Color.white
                )
                .foregroundColor(
                  selectedAscentType == ascentType ? .white : Color.newTextColor
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }

  private var attemptsCountView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Attempts Count")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal)

      HStack(spacing: 15) {
        // Decrement button
        Button(action: {
          withAnimation {
            if attemptsCount == 2 {
              attemptsCount = nil
            } else if let count = attemptsCount, count > 2 {
              attemptsCount = count - 1
            }
          }
        }) {
          Image(systemName: "minus.circle.fill")
            .font(.title2)
            .foregroundColor(attemptsCount == nil ? Color.gray.opacity(0.5) : Color.newPrimaryColor)
        }
        .disabled(attemptsCount == nil)

        // Text field for attempts count
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .frame(width: 80, height: 40)

          if attemptsCount == nil {
            Text("None")
              .font(.headline)
              .foregroundColor(Color.gray.opacity(0.5))
          }

          TextField(
            "",
            text: Binding(
              get: {
                if let count = attemptsCount {
                  return "\(count)"
                } else {
                  return ""
                }
              },
              set: { newValue in
                if let count = Int(newValue), count >= 2 {
                  attemptsCount = count
                } else if newValue.isEmpty {
                  attemptsCount = nil
                }
              }
            )
          )
          .keyboardType(.numberPad)
          .multilineTextAlignment(.center)
          .font(.headline)
          .foregroundColor(Color.newTextColor)
          .frame(width: 60)
          .focused($isAttemptsCountFocused)
        }

        // Increment button
        Button(action: {
          withAnimation {
            if attemptsCount == nil {
              attemptsCount = 2
            } else if let count = attemptsCount {
              attemptsCount = count + 1
            }
          }
        }) {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .foregroundColor(Color.newPrimaryColor)
        }
      }
      .padding(.horizontal, 20)
    }
    .transition(.opacity.combined(with: .move(edge: .top)))
    .animation(.easeInOut, value: ascentRequiresAttemptCount)
  }

  private var gradeView: some View {
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
  }

  private var ratingView: some View {
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
  }

  private var notesView: some View {
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
  }

  private var submitButton: some View {
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

  private func submitAscent() async {
    guard let route = route else {
      errorMessage = "Route information is missing"
      return
    }

    isSubmitting = true
    defer { isSubmitting = false }

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
        ascentType: selectedAscentType,
        numberOfAttempts: attemptsCount.map { Int32($0) },
        proposedGrade: authViewModel.getGradeSystem().convertStringToGrade(selectedGrade),
        rating: Int32(rating)
      ), authViewModel.getAuthData(), { errorMessage = $0 })

    if result == "" {
      onAscentLogged?()
      dismiss()
    }
  }
}
