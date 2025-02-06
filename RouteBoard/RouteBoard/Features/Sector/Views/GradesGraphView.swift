//
//  GradesGraphView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.07.2024..
//

import SwiftUI

private struct GradeGraphCapsule: View {
  let proxy: GeometryProxy
  let grade: GradeCount
  let gradesModel: GradesGraphModel
  @Binding var animate: Bool

  var body: some View {
    let height = max(5, proxy.size.height * CGFloat(grade.count) / CGFloat(gradesModel.maxCount))
    let color = gradesModel.gradeColor[grade.grade]?.color ?? Color.newPrimaryColor
    let textColor = height > 20 ? .white : Color.newTextColor

    Rectangle()
      .clipShape(
        .rect(
          topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
          topTrailingRadius: 40)
      )
      .foregroundStyle(color)
      .frame(
        width: 40,
        height: animate
          ? height : 0
      )
      .animation(.spring, value: animate)
      .overlay(
        Text(String(grade.count))
          .foregroundStyle(textColor)
          .font(.subheadline)
          .fontWeight(.semibold)
          .padding(.horizontal, 5)
          .padding(.top, height > 20 ? 5 : -20),
        alignment: .top
      )
  }
}

struct GradesGraphView: View {
  @State private var animate = false

  let gradesModel: GradesGraphModel

  var body: some View {
    return GeometryReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .bottom, spacing: 2) {
          ForEach(gradesModel.sortedGradesList) { grade in
            VStack {
              GradeGraphCapsule(
                proxy: proxy,
                grade: grade,
                gradesModel: gradesModel,
                animate: $animate
              )

              Text(grade.grade)
                .foregroundStyle(Color.newTextColor)
                .fontWeight(.semibold)
                .padding(0)
                .lineLimit(1)
            }
          }
        }
        .padding(.horizontal, 20)
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          withAnimation {
            animate = true
          }
        }
      }
    }
  }
}

#Preview {
  GradesGraphView(
    gradesModel: GradesGraphModel(grades: [
      GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3),
      GradeCount(grade: "6a", count: 1),
    ]))
}
