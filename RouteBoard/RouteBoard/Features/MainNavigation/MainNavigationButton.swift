import Foundation
import SwiftUI

struct MainNavigationButton: View {
    var iconName: String;
    var text: String;
    var tag: Int;
    @Binding var selectedTab: Int;
    var isSelected: Bool {
        selectedTab == tag
    }

    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            VStack(alignment: .center, spacing: 2) {
                Image(systemName: iconName)
                    .foregroundColor(isSelected ? .buttonPrimary : .white)
                    .clipShape(Circle())
                    .font(.title2)
                Text(text)
                    .foregroundColor(isSelected ? .buttonPrimary : .white)
                    .font(.footnote)
            }
            .padding(20)
        }
    }
}
