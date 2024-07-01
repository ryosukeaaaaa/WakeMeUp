import SwiftUI

struct ContentView: View {
    @StateObject private var alarmStore = AlarmStore()
    @State private var showingAlarmLanding = false
    @State private var currentAlarmId: String?
    @State private var currentGroupId: String?
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false
    
    @State private var MissionView = false
    
    @StateObject private var missionState = MissionState()

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
                    Button(action: {
                        MissionView = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Mission")
                                .font(.headline)
                        }
                        .padding(10)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $MissionView) {
                        Pre_Mission()
                            .onAppear {
                            MissionView = false
                            }
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
