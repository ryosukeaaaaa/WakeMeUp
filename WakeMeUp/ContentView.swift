import SwiftUI

struct ContentView: View {
    @StateObject private var alarmStore = AlarmStore()
    @State private var showingAlarmLanding = false
    @State private var currentAlarmId: String?
    @State private var currentGroupId: String?
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false

    var body: some View {
        NavigationStack {
            TabView {
                NavigationStack {
                    AlarmListView(alarmStore: alarmStore)
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("アラーム")
                }

                NavigationStack {
                    VStack {
                        // 遷移するためのボタン
                        NavigationLink("ミッションビューへ", value: "mission")
                            .padding()
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "mission" {
                            Pre_Mission()
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "flag")
                    Text("ミッション")
                }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
            }
        }
    }
}
