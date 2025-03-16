// Created with <3 on 16.03.2025.

import SwiftUI

struct FriendsListView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Friends")
          .font(.headline)
          .foregroundColor(Color.newTextColor)

        Spacer()

        Button(action: {}) {
          Text("See All")
            .font(.subheadline)
            .foregroundColor(Color.newPrimaryColor)
        }
      }

      // API doesn't provide friends yet, so we'll keep the mock data for now
      ForEach(mockFriends) { friend in
        HStack(spacing: 12) {
          Image(systemName: friend.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
            .padding(4)
            .background(Color.gray.opacity(0.3))
            .clipShape(Circle())

          Text(friend.name)
            .foregroundColor(Color.newTextColor)

          Spacer()

          Button(action: {}) {
            Text("Follow")
              .font(.caption)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.newPrimaryColor)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
        }
        .padding(.vertical, 4)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}

// Mock data for friends (API doesn't provide this yet)
private let mockFriends = [
  Friend(name: "Alex Honnold", image: "person.fill"),
  Friend(name: "Adam Ondra", image: "person.fill"),
  Friend(name: "Janja Garnbret", image: "person.fill"),
  Friend(name: "Chris Sharma", image: "person.fill"),
  Friend(name: "Shauna Coxsey", image: "person.fill"),
]

struct Friend: Identifiable {
  let id = UUID()
  let name: String
  let image: String
}
