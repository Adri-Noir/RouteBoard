//
//  SimpleRoute.swift
//  RouteBoard
//
//  Created with <3 on 08.07.2024..
//

import SwiftUI

class SimpleRoute: Identifiable {
  var id: String
  var name: String
  var grade: String
  var numberOfAscents: Int

  init(id: String, name: String, grade: String, numberOfAscents: Int) {
    self.id = id
    self.name = name
    self.grade = grade
    self.numberOfAscents = numberOfAscents
  }
}
