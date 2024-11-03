//
//  GradesGraphModel.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.07.2024..
//

import Foundation

struct Grade: Identifiable {
    let grade: String
    
    var id: String { grade }
}

struct GradeCount: Identifiable {
    let grade: String
    let count: Int
    
    var id: String { grade }
}

struct GradesGraphModel  {
    let grades: [GradeCount]
    
    let gradeStandard: ClimbingGrades = FrenchClimbingGrades()
    var gradesMap: Dictionary<String, GradeCount> {
        var map = Dictionary<String, GradeCount>()
        
        grades.forEach { grade in
            map[grade.grade] = grade
            
        }
        
        return map
    }
    
    var sortedGradesList: [Grade] {
        return gradeStandard.climbingGrades.compactMap { grade in
            if gradesMap[grade] != nil {
                return Grade(grade: grade)
            } else {
                return nil
            }
        }
    }
    
    var maxCount: Int {
        var max: Int = 0
        grades.forEach { grade in
            if grade.count > max {
                max = grade.count
            }
        }
        
        return max
    }
    
    var minGrade: String {
        return sortedGradesList[0].grade
    }
    
    var maxGrade: String {
        return sortedGradesList[sortedGradesList.count - 1].grade
    }
}
