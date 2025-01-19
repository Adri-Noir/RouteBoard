//
//  InformationRectanglesView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 03.07.2024..
//

import GeneratedClient
import SwiftUI

struct InformationRectangle<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      RoundedRectangle(cornerRadius: 20, style: .circular)
        .fill(Color.backgroundGray)
        .frame(height: 90)

      VStack(alignment: .leading, spacing: 7) {
        content
      }
      .padding()
    }
  }
}

struct InformationRectanglesView: View {
  let sectorDetails: SectorDetails?
  private var gradesGraphModel: GradesGraphModel {
    GradesGraphModel(grades: [
      GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3),
      GradeCount(grade: "6a", count: 1),
    ])
  }

  init(sectorDetails: SectorDetails?) {
    self.sectorDetails = sectorDetails
  }

  private func handleLike() {
    print("Like")
  }

  private func handleOpenRoutesView() {
    print("Open routes")
  }

  var body: some View {
    VStack(spacing: 15) {
      HStack(alignment: .center, spacing: 15) {

        InformationRectangle {
          Text(String(sectorDetails?.routes?.count ?? 0))
            .bold()
            .font(.title2)
          HStack {
            Image(systemName: "arrow.up.square")
            Text("Routes")

          }
        }
        .onTapGesture {
          handleOpenRoutesView()
        }

        InformationRectangle {
          Text("34")
            .bold()
            .font(.title2)
          HStack {
            Image(systemName: "hand.thumbsup")
            Text("Likes")
          }
        }
        .onTapGesture {
          handleLike()
        }
      }

      HStack(alignment: .center, spacing: 15) {
        InformationRectangle {
          Text("20")
            .bold()
            .font(.title2)
          HStack {
            Image(systemName: "checkmark.circle")
            Text("Ascents")
          }
        }

        InformationRectangle {
          Text(gradesGraphModel.minGrade + " - " + gradesGraphModel.maxGrade)
            .bold()
            .font(.title2)
          HStack {
            Image(systemName: "grid.circle.fill")
            Text("Grades")
          }

        }
      }
    }
    .padding(.horizontal)
  }
}

extension View {
  @ViewBuilder
  private func onTapBackgroundContent(enabled: Bool, _ action: @escaping () -> Void) -> some View {
    if enabled {
      Color.clear
        .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
  }

  func onTapBackground(enabled: Bool, _ action: @escaping () -> Void) -> some View {
    background(
      onTapBackgroundContent(enabled: enabled, action)
    )
  }
}
