import SwiftUI

struct ContentView: View {
    @StateObject private var alarmStore = AlarmStore()
    @State private var showingAlarmLanding = false
    @State private var currentAlarmId: String?
    @State private var currentGroupId: String?
    @State private var debugMessage = ""

    var body: some View {
        TabView {
            NavigationStack {
                AlarmListView(alarmStore: alarmStore)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("アラーム")
            }
            
            NavigationStack {
                Pre_Mission()
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
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showingAlarmLanding) {
            if let alarmId = currentAlarmId, let groupId = currentGroupId {
                NavigationStack {
                    AlarmLandingView(alarmStore: alarmStore, alarmId: alarmId, groupId: groupId, isPresented: $showingAlarmLanding)
                }
            } else {
                Text("No alarm information available")
                    .onAppear {
                        print("ContentView: No alarm information available. currentAlarmId: \(String(describing: currentAlarmId)), currentGroupId: \(String(describing: currentGroupId))")
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAlarmLanding"))) { notification in
            print("ContentView: Received ShowAlarmLanding notification")
            if let alarmId = notification.userInfo?["alarmId"] as? String,
               let groupId = notification.userInfo?["groupId"] as? String {
                print("ContentView: Received alarmId: \(alarmId) and groupId: \(groupId)")
                DispatchQueue.main.async {
                    self.currentAlarmId = alarmId
                    self.currentGroupId = groupId
                    self.showingAlarmLanding = true
                    self.debugMessage = "Received notification with alarmId: \(alarmId) and groupId: \(groupId)"
                }
            } else {
                print("ContentView: Failed to extract alarmId or groupId from notification")
                self.debugMessage = "Received notification without proper alarm information"
            }
            print(self.debugMessage)
        }
        .overlay(
            Text(debugMessage)
                .foregroundColor(.red)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .opacity(debugMessage.isEmpty ? 0 : 1)
        )
    }
}
