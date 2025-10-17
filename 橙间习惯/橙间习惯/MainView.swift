import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("晨光", systemImage: "sun.and.horizon")
                }

            MyJournalView()
                .tabItem {
                    Label("时光", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(JournalStore())
}
