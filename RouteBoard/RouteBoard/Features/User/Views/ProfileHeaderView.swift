// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct ProfileHeaderExpandedView: View {
  let userProfile: UserProfile?
  let username: String?

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      Spacer()

      HStack(alignment: .center, spacing: 16) {
        Spacer()

        if let profilePhotoUrl = userProfile?.profilePhoto?.url, !profilePhotoUrl.isEmpty {
          AsyncImage(url: URL(string: profilePhotoUrl)) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
            default:
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(Color.newBackgroundGray)
            }
          }
          .frame(width: 80, height: 80)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
          Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(userProfile?.username ?? username ?? "User")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)

          Text("Climber Profile")
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
        }

        Spacer()
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)

      Spacer()
    }
  }
}

struct ProfileHeaderCollapsedView: View {
  let userProfile: UserProfile?
  let username: String?
  let headerVisibleRatio: CGFloat
  let safeAreaInsets: UIEdgeInsets
  let dismiss: DismissAction

  var body: some View {
    HStack {
      Button(action: {
        dismiss()
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(8)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }

      Spacer()

      Group {
        if let profilePhotoUrl = userProfile?.profilePhoto?.url, !profilePhotoUrl.isEmpty {
          AsyncImage(url: URL(string: profilePhotoUrl)) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
            default:
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(Color.newBackgroundGray)
            }
          }
          .frame(width: 40, height: 40)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
          Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }

        Text(userProfile?.username ?? username ?? "User")
          .fontWeight(.bold)
          .foregroundColor(.white)
      }
      .opacity(1 - headerVisibleRatio)

      Spacer()
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.bottom, 5)
    .background(
      Color.newPrimaryColor.ignoresSafeArea().background(.ultraThinMaterial).opacity(
        1 - headerVisibleRatio)
    )
    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
    .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
    .padding(.top, safeAreaInsets.top)
  }
}
