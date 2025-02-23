// Created with <3 on 23.02.2025.

import SwiftUI

struct RecentlyViewedView: View {
  @State private var isExpanded = false

  var numberOfRoutes: Int {
    isExpanded ? 6 : 2
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "clock")
          .foregroundColor(Color.white)

        Text("Recently Viewed")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.white)

        Spacer()

        Button(action: {
          withAnimation {
            isExpanded.toggle()
          }
        }) {
          Text(isExpanded ? "Show Less" : "Show More")
            .font(.caption2)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      }

      LazyVStack(spacing: 0) {
        ForEach(0..<numberOfRoutes, id: \.self) { index in
          VStack(spacing: 0) {
            HStack {
              Image("TestingSamples/limski/pikachu")  // Placeholder image
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(10)

              VStack(alignment: .leading) {
                HStack(spacing: 4) {
                  Text("Crag Name")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(Color.newTextColor)

                  Text("Crag")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text("Sector Name")
                  .font(.caption)
                  .foregroundColor(.gray)
              }

              Spacer()

              Image(systemName: "chevron.right")
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)

            if index < numberOfRoutes - 1 {
              Divider()
                .padding(.horizontal, 10)
            }
          }
        }
      }
      .background(Color.white)
      .cornerRadius(10)
      .animation(.easeInOut(duration: 0.2), value: isExpanded)
      .shadow(color: Color.white.opacity(0.5), radius: 50, x: 0, y: 10)
    }
    .padding(.horizontal, 20)
  }
}

#Preview {
  RecentlyViewedView()
}
