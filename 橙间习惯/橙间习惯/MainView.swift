import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("仪式", systemImage: "sun.and.horizon")
                }

            MyJournalView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(JournalStore())
}
