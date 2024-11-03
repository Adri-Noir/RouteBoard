//
//  GradesGraphView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.07.2024..
//

import SwiftUI

struct GradesGraphView: View {
    @State private var animate = false
    
    let gradesModel: GradesGraphModel
    
    var body: some View {
        let dataMap = gradesModel.gradesMap
        let categories = gradesModel.sortedGradesList
        let maxCount = gradesModel.maxCount
        
        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(categories) { category in
                    VStack {
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .foregroundStyle(Color(red: 0.78, green: 0.62, blue: 0.52))
                                .frame(width: 40, height: animate ? proxy.size.height * CGFloat(dataMap[category.grade]!.count) / CGFloat(maxCount) - 40 : 0)
                                .animation(.spring, value: animate)
                            
                            Text(String(dataMap[category.grade]!.count))
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding()
                        }
                        
                        Text(category.grade)
                            .foregroundStyle(.black)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    }
                    
                    
                }
            }
            .onAppear {
                withAnimation {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    GradesGraphView(gradesModel: GradesGraphModel(grades: [GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3), GradeCount(grade: "6a", count: 1)]))
}
