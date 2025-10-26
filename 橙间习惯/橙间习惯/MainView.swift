import SwiftUI

private enum MainTab: Int {
    case morning
    case journal
}

struct MainView: View {
    @State private var selectedTab: MainTab = .morning

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label {
                        Text("晨光")
                    } icon: {
                        Image(systemName: "sun.and.horizon")
                            .symbolVariant(selectedTab == .morning ? .fill : .none)
                    }
                }
                .tag(MainTab.morning)

            MyJournalView()
                .tabItem {
                    Label {
                        Text("时光")
                    } icon: {
                        Image(systemName: "person.crop.circle")
                            .symbolVariant(selectedTab == .journal ? .fill : .none)
                    }
                }
                .tag(MainTab.journal)
        }
        .tint(.black)
    }
}

#Preview {
    MainView()
        .environmentObject(JournalStore())
}
