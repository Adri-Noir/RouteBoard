//
//  RouteAscentsView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

private struct RouteAscentRowView: View {
  let ascent: Components.Schemas.AscentDto
  @EnvironmentObject private var authViewModel: AuthViewModel

  var climbTypes: some View {
    HStack(alignment: .top, spacing: 10) {
      VStack(alignment: .leading, spacing: 5) {
        // Climb types
        if let climbTypes = ascent.climbTypes, !climbTypes.isEmpty {
          HStack {
            Image(systemName: "figure.climbing")
              .foregroundColor(Color.newPrimaryColor)
          }
        }

        // Rock types
        if let rockTypes = ascent.rockTypes, !rockTypes.isEmpty {
          HStack {
            Image(systemName: "mountain.2")
              .foregroundColor(Color.newPrimaryColor)
          }
        }

        // Hold types
        if let holdTypes = ascent.holdTypes, !holdTypes.isEmpty {
          HStack {
            Image(systemName: "hand.raised")
              .foregroundColor(Color.newPrimaryColor)
          }
        }
      }

      VStack(alignment: .leading, spacing: 5) {
        if let climbTypes = ascent.climbTypes, !climbTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(climbTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
        }

        if let rockTypes = ascent.rockTypes, !rockTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(rockTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
        }

        if let holdTypes = ascent.holdTypes, !holdTypes.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
              ForEach(holdTypes, id: \.rawValue) { type in
                Text(type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(Color.newBackgroundGray)
                  .cornerRadius(5)
                  .foregroundColor(Color.newTextColor)
              }
            }

          }
        }

        if ascent.climbTypes?.isEmpty == true, ascent.rockTypes?.isEmpty == true,
          ascent.holdTypes?.isEmpty == true
        {
          Text("No tags")
            .font(.caption)
            .foregroundColor(Color.gray)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 15) {
        if let profilePhotoUrl = ascent.userProfilePhotoUrl, !profilePhotoUrl.isEmpty {
          AsyncImage(url: URL(string: profilePhotoUrl)) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.newTextColor)
            default:
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
            }
          }
          .frame(width: 50, height: 50)
          .clipShape(Circle())
        } else {
          Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
            .foregroundColor(Color.newTextColor)
        }

        VStack(alignment: .leading, spacing: 3) {
          Text(ascent.username ?? "Unknown Climber")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color.newTextColor)

          if let ascentDate = ascent.ascentDate,
            let date = ISO8601DateFormatter().date(from: ascentDate)
          {
            Text(date, style: .date)
              .font(.caption)
              .foregroundColor(Color.gray)
          }
        }

        Spacer()

        if let ascentType = ascent.ascentType {
          Text(ascentType.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ascentTypeColor(ascentType))
            .cornerRadius(8)
        }
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)

      Divider()
        .padding(.horizontal, 15)

      // Climb details
      HStack(alignment: .center, spacing: 15) {
        // Grade
        VStack(alignment: .center, spacing: 3) {
          Text("Grade")
            .font(.caption)
            .foregroundColor(Color.gray)

          Text(authViewModel.getGradeSystem().convertGradeToString(ascent.proposedGrade))
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color.newPrimaryColor)
        }
        .frame(width: 70)

        Divider()
          .frame(height: 50)

        climbTypes
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)

      // Notes section if available
      if let notes = ascent.notes, !notes.isEmpty {
        Divider()
          .padding(.horizontal, 15)

        HStack(alignment: .center) {
          Image(systemName: "text.quote")
            .foregroundColor(Color.newPrimaryColor)
            .padding(.top, 2)

          Text(notes)
            .font(.caption)
            .foregroundColor(Color.newTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
      }

      // Rating if available
      if let rating = ascent.rating, rating > 0 {
        Divider()
          .padding(.horizontal, 15)

        HStack {
          Text("Rating:")
            .font(.caption)
            .foregroundColor(Color.gray)

          HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
              Image(systemName: star <= rating ? "star.fill" : "star")
                .foregroundColor(star <= rating ? .yellow : .gray)
                .font(.caption)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
      }

      // Number of attempts if available
      if let attempts = ascent.numberOfAttempts, attempts > 0 {
        HStack {
          Text("Attempts: \(attempts)")
            .font(.caption)
            .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
      }
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.vertical, 5)
  }

  // Helper function to determine color based on ascent type
  private func ascentTypeColor(_ ascentType: Components.Schemas.AscentType) -> Color {
    switch ascentType {
    case .Onsight:
      return Color.red
    case .Flash:
      return Color.blue
    case .Redpoint:
      return Color.orange
    case .Aid:
      return Color.purple
    }
  }
}

struct AllAscentsView: View {
  var route: RouteDetails?
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {

    ScrollView {
      VStack(spacing: 15) {
        if let ascents = route?.ascents, !ascents.isEmpty {
          ForEach(ascents, id: \.id) { ascent in
            RouteAscentRowView(ascent: ascent)
          }
        } else {
          Text("No ascents recorded yet")
            .font(.headline)
            .foregroundColor(Color.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 50)
        }
      }
      .padding(.vertical, 15)
    }
    .background(Color.newBackgroundGray.ignoresSafeArea())
  }
}
