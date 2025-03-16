import Foundation
import GeneratedClient
import SwiftUI

struct SingleResultView: View {
  var result: SearchResultDto

  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    HStack(spacing: 12) {
      Image("TestingSamples/limski/pikachu")
        .resizable()
        .scaledToFill()
        .frame(width: 60, height: 60)
        .cornerRadius(10)

      VStack(alignment: .leading) {
        // Display name based on entity type
        switch result.entityType {
        case .Route:
          routeResultView
        case .Sector:
          sectorResultView
        case .Crag:
          cragResultView
        case .UserProfile:
          userProfileResultView
        default:
          unknownItemView
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(10)
    .background(Color.white)
    .cornerRadius(10)
    .shadow(color: Color.white.opacity(0.4), radius: 25, x: 0, y: 0)
  }

  private var routeResultView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 4) {
        Text(result.routeName ?? "Unknown Route")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Text("Route")
          .font(.caption2)
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.blue.opacity(0.7))
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }

      Text(result.routeSectorName ?? "Unknown Sector")
        .font(.caption)
        .foregroundColor(.gray)

      if let difficulty = result.routeDifficulty {
        Text("Grade: \(authViewModel.getGradeSystem().convertGradeToString(difficulty))")
          .font(.caption)
          .foregroundColor(.gray)
      }
    }
  }

  private var sectorResultView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 4) {
        Text(result.sectorName ?? "Unknown Sector")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Text("Sector")
          .font(.caption2)
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.green.opacity(0.7))
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }

      Text(result.sectorCragName ?? "Unknown Crag")
        .font(.caption)
        .foregroundColor(.gray)

      if let routesCount = result.sectorRoutesCount {
        Text("\(routesCount) Routes")
          .font(.caption)
          .foregroundColor(.gray)
      }
    }
  }

  private var cragResultView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 4) {
        Text(result.cragName ?? "Unknown Crag")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Text("Crag")
          .font(.caption2)
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.orange.opacity(0.7))
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }

      if let sectorsCount = result.cragSectorsCount, let routesCount = result.cragRoutesCount {
        Text("\(sectorsCount) Sectors, \(routesCount) Routes")
          .font(.caption)
          .foregroundColor(.gray)
      }
    }
  }

  private var userProfileResultView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 4) {
        Text(result.profileUsername ?? "Unknown User")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Text("User")
          .font(.caption2)
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.purple.opacity(0.7))
          .clipShape(RoundedRectangle(cornerRadius: 4))

        Spacer()

        if let ascentsCount = result.ascentsCount {
          Text("\(ascentsCount) Ascents")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }
    }
  }

  private var unknownItemView: some View {
    Text("Unknown Item")
      .font(.headline)
      .foregroundColor(Color.newTextColor)
  }
}
