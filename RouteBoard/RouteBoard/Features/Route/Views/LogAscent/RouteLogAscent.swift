// Created with <3 on 25.02.2025.

import GeneratedClient
import SwiftUI

struct RouteLogAscent: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  let routeId: String
  let routeGrade: Components.Schemas.ClimbingGrade?

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
  @State private var headerVisibleRatio: CGFloat = 1

  private let logAscentClient = LogAscentClient()

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
            Text("Log Ascent")
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
        VStack(spacing: 20) {
          datePickerView

          Group {
            ascentTypeView
          }
          .padding(16)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          if ascentRequiresAttemptCount {
            Group {
              attemptsCountView
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, ThemeExtension.horizontalPadding)
          }

          Group {
            gradeView
          }
          .padding(16)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          Group {
            climbTypesView
          }
          .padding(16)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          Group {
            ratingView
          }
          .padding(16)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          Group {
            notesView
          }
          .padding(16)
          .background(Color.white)
          .cornerRadius(10)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          submitButton
        }
        .padding(.top, 20)
        .padding(.bottom, safeAreaInsets.bottom)
      }
      .contentMargins(.bottom, safeAreaInsets.bottom, for: .scrollContent)
      .scrollDismissesKeyboard(.interactively)
      .task {
        selectedGrade = authViewModel.getGradeSystem().convertGradeToString(routeGrade)
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
      .onTapGesture {
        isAttemptsCountFocused = false
      }
      .alert(message: $errorMessage)
    }
    .navigationBarHidden(true)
  }

  // MARK: - Subviews

  private var headerView: some View {
    VStack {
      Spacer()
      HStack {
        backButtonView
        Text("Log Ascent")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Color.newPrimaryColor)
        Spacer()
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  private var datePickerView: some View {
    DatePicker(
      "Ascent Date",
      selection: $ascentDate,
      displayedComponents: .date
    )
    .font(.headline)
    .fontWeight(.semibold)
    .colorScheme(.light)
    .foregroundStyle(Color.newTextColor)
    .accentColor(Color.newPrimaryColor)
    .padding()
    .background(Color.white)
    .cornerRadius(10)
    .padding(.horizontal, ThemeExtension.horizontalPadding)
  }

  private var ascentTypeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Ascent Type")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)

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
                  selectedAscentType == ascentType ? Color.newPrimaryColor : Color.newBackgroundGray
                )
                .foregroundColor(
                  selectedAscentType == ascentType ? .white : Color.newTextColor
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .scrollTransition { content, phase in
              content
                .opacity(phase.isIdentity ? 1 : 0)
                .scaleEffect(phase.isIdentity ? 1 : 0)
            }
          }
        }
        .scrollTargetLayout()
      }
    }
  }

  private var attemptsCountView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Attempts Count")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)

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
            .fill(Color.newBackgroundGray)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .frame(width: 80, height: 40)

          if attemptsCount == nil {
            Text("None")
              .font(.headline)
              .foregroundColor(Color.newTextColor.opacity(0.5))
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

        Spacer()
      }
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
                .background(
                  selectedGrade == grade ? Color.newPrimaryColor : Color.newBackgroundGray
                )
                .foregroundColor(selectedGrade == grade ? .white : Color.newTextColor)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .scrollTransition { content, phase in
              content
                .opacity(phase.isIdentity ? 1 : 0)
                .scaleEffect(phase.isIdentity ? 1 : 0)
            }
            .id(grade)
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $scrollPosition, anchor: .center)
    }
  }

  private var climbTypesView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Climb Types")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)

      VStack(spacing: 15) {
        climbTypeSection(title: "Style", types: [.Endurance, .Powerful, .Technical])
        climbTypeSection(
          title: "Rock Type", types: [.Vertical, .Overhang, .Roof, .Slab, .Arete, .Dihedral])
        climbTypeSection(
          title: "Hold Type", types: [.Crack, .Crimps, .Slopers, .Pinches, .Jugs, .Pockets])
      }
    }
  }

  private func climbTypeSection(title: String, types: [UserClimbingType]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(Color.gray)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(types, id: \.self) { climbType in
            Button(action: {
              withAnimation {
                toggleClimbType(climbType)
              }
            }) {
              Text(climbType.rawValue)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                  selectedClimbType.contains(climbType)
                    ? Color.newPrimaryColor : Color.newBackgroundGray
                )
                .foregroundColor(
                  selectedClimbType.contains(climbType) ? .white : Color.newTextColor
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .scrollTransition { content, phase in
              content
                .opacity(phase.isIdentity ? 1 : 0)
                .scaleEffect(phase.isIdentity ? 1 : 0)
            }
          }
        }
        .scrollTargetLayout()
      }
    }
  }

  private func toggleClimbType(_ type: UserClimbingType) {
    if let index = selectedClimbType.firstIndex(where: { $0 == type }) {
      selectedClimbType.remove(at: index)
    } else {
      selectedClimbType.append(type)
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
  }

  private var notesView: some View {
    TextAreaField(
      title: "Notes",
      text: $notes,
      placeholder: "Enter notes here... (optional)",
      padding: 0,
      backgroundColor: Color.newBackgroundGray
    )
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
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .padding(.top, 10)
    .disabled(isSubmitting)
  }

  private func submitAscent() async {
    isSubmitting = true
    defer { isSubmitting = false }

    let result = await logAscentClient.call(
      LogAscentInput(
        routeId: routeId,
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
      dismiss()
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
}

#Preview {
  Navigator { _ in
    AuthInjectionMock {
      RouteLogAscent(routeId: "123", routeGrade: .F_6a)
    }
  }
}
