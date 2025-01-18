//
//  RoutesListView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 08.07.2024..
//

import SwiftUI

struct RoutesListView: View {
  @State private var searchQuery: String = ""

  var routes: [SimpleRoute]

  var body: some View {

    Text("Routes for sector")
    List(routes) { route in
      HStack {
        Text(route.name)
        Text(route.grade)
        Text(String(route.numberOfAscents))
      }
    }
    .searchable(text: $searchQuery, placement: .sidebar)

  }
}

#Preview {
  RoutesListView(routes: [SimpleRoute(id: "1", name: "Apaches", grade: "6b", numberOfAscents: 1)])
}
