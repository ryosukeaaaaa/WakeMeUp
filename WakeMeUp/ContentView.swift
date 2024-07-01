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
                        NavigationLink(value: "PreMission") {
                            Text("ミッションビューへ")
                                .padding()
                        }
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "PreMission" {
                            Pre_Mission()
                        }
                    }
                    .onAppear {
                        // 遷移前の初期化処理を行う
                        isMissionViewActive = false
                    }
                }
                .tabItem {
                    Image(systemName: "flag")
                    Text("ミッション")
                }
                
                NavigationStack {
                    StatusView()
                }
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("習得状況")
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
