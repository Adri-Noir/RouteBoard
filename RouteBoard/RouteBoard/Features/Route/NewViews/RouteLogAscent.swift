// Created with <3 on 25.02.2025.

import GeneratedClient
import SwiftUI

struct RouteLogAscent: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  let route: RouteDetails?

  @State private var selectedGrade: String = "4a"
  @State private var selectedClimbType: [String] = []
  @State private var rating: Int = 0
  @State private var comment: String = ""
  @State private var isSubmitting: Bool = false
  @State private var scrollPosition: String?

  @FocusState private var isCommentFocused: Bool

  private let climbTypes = ["Onsight", "Flash", "Redpoint", "Pinkpoint", "Top Rope", "Attempt"]

  private var grades: [String] {
    authViewModel.getGradeSystem().climbingGrades
  }

  init(route: RouteDetails?) {
    self.route = route
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
            Text("Comment")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newTextColor)
              .padding(.horizontal)

            TextEditor(text: $comment)
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
              .focused($isCommentFocused)
              .onTapBackground(enabled: isCommentFocused) {
                isCommentFocused = false
              }
          }
          .padding(.horizontal, 20)

          Button(action: {
            submitAscent()
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
        .padding(.vertical)
      }
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
    }
    .background(Color.newBackgroundGray)
  }

  private func submitAscent() {
    isSubmitting = true

    // Here you would implement the API call to submit the ascent
    // For now, we'll just simulate a delay and then dismiss
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      isSubmitting = false
      dismiss()
    }
  }
}
