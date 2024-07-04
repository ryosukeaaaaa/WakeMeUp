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
                    HomeMission()
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
            .navigationTitle("Home")
            .navigationDestination(isPresented: $showingAlarmLanding) {
                if let alarmId = currentAlarmId, let groupId = currentGroupId {
                    AlarmLandingView(alarmStore: alarmStore, alarmId: alarmId, groupId: groupId, isPresented: $showingAlarmLanding)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAlarmLanding"))) { notification in
            if let userInfo = notification.userInfo,
               let alarmId = userInfo["alarmId"] as? String,
               let groupId = userInfo["groupId"] as? String {
                currentAlarmId = alarmId
                currentGroupId = groupId
                showingAlarmLanding = true
                debugMessage = "Received notification: AlarmId = \(alarmId), GroupId = \(groupId)"
            } else {
                debugMessage = "Received notification but couldn't extract alarmId or groupId"
            }
        }
        .overlay(
            Text(debugMessage)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .opacity(debugMessage.isEmpty ? 0 : 1)
        )
    }
}
