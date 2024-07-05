import SwiftUI

struct ContentView: View {
    @StateObject private var alarmStore = AlarmStore()
    @State private var showingAlarmLanding = false
    @State private var currentAlarmId: String?
    @State private var currentGroupId: String?
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false
    
    @State private var isPermissionGranted = true // 通知設定の確認
    
    @State private var showAlert = false

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
            .navigationTitle("Home") // <backが<Homeに
            // 画面開始画面
            .navigationDestination(isPresented: $showingAlarmLanding) {
                if let alarmId = currentAlarmId, let groupId = currentGroupId {
                    AlarmLandingView(alarmStore: alarmStore, alarmId: alarmId, groupId: groupId, isPresented: $showingAlarmLanding)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                checkNotificationPermission()
                if isPermissionGranted{
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("通知の許可が必要"),
                    message: Text("アラームを有効にするには通知の許可が必要です。設定から通知を許可してください。"),
                    dismissButton: .default(Text("OK"))
                )
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
//        .overlay(
//            Text(debugMessage)
//                .padding()
//                .background(Color.black.opacity(0.7))
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                .opacity(debugMessage.isEmpty ? 0 : 1)
//        )
    }
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
                if !self.isPermissionGranted {
                    requestNotificationPermission()
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    print("通知の許可が得られました")
                } else {
                    print("通知の許可が得られませんでした")
                }
            }
        }
    }
}
