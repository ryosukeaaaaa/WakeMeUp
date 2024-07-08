import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var showingAlarmLanding: Bool = false
    // @State private var showingAlarmLanding = false
    // @State private var currentAlarmId: String?
    // @State private var currentGroupId: String?
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
            .navigationTitle("Home")
            .navigationDestination(isPresented: $alarmStore.showingAlarmLanding) {
                AlarmLandingView(alarmStore: alarmStore, groupId: alarmStore.groupId, isPresented: $alarmStore.showingAlarmLanding)
                        .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                checkNotificationPermission()
                print("aaaaa", alarmStore.showingAlarmLanding)
                self.showingAlarmLanding = self.alarmStore.showingAlarmLanding
                if !isPermissionGranted {
                    showAlert = true
                }
            }
            .onChange(of: alarmStore.showingAlarmLanding) {
                // showingAlarmLanding の変更を監視して、必要なアクションを実行
                print("showingAlarmLanding changed to: \(alarmStore.showingAlarmLanding)")
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
            if let outerUserInfo = notification.userInfo,
               let groupId = outerUserInfo["groupId"] as? String {
                alarmStore.groupId = groupId
                alarmStore.showingAlarmLanding = true
                debugMessage = "Received notification: GroupId = \(alarmStore.groupId)"
            } else {
                debugMessage = "Received notification but couldn't extract groupId"
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
