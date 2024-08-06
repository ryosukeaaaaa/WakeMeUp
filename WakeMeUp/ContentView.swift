import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    // @State private var currentAlarmId: String?
    // @State private var currentGroupId: String?
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false
    @State private var isPermissionGranted = true // 通知設定の確認
    @State private var showAlert = false
    
    @State private var navigationPath = NavigationPath()
    
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(path: $navigationPath){
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
                    GachaView()
                }
                .tabItem {
                    Image(systemName: "die.face.5")
                    Text("ガチャ")
                }
                
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
            }
            // .navigationTitle("Home")
            .navigationDestination(isPresented: $alarmStore.showingAlarmLanding) {
                AlarmLandingView(alarmStore: alarmStore, groupId: alarmStore.groupIds, isPresented: $alarmStore.showingAlarmLanding)
                        .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                checkNotificationPermission()
                if !isPermissionGranted {
                    showAlert = true
                }
                print("aaaaa", alarmStore.showingAlarmLanding)
            }
            .onChange(of: alarmStore.showingAlarmLanding) {
                // showingAlarmLanding の変更を監視して、必要なアクションを実行
                print("showingAlarmLanding changed to: \(alarmStore.showingAlarmLanding)")
            }
            .onChange(of: scenePhase) {
                //            if scenePhase == .background {
                //                print("バックグラウンド（.background）")
                //            }
                if scenePhase == .active {
                    let result = alarmStore.groupIdsForAlarmsWithinTimeRange() // 範囲内に設定したアラームがあるか
                    alarmStore.groupIds = result.groupIds
                    alarmStore.Sound = result.firstSound ?? "デフォルト_medium.mp3"
                    print("groupids:", alarmStore.groupIds)
                    if !alarmStore.groupIds.isEmpty {
                        alarmStore.showingAlarmLanding = true
                        print("音になった")
                        print(alarmStore.showingAlarmLanding)
                    }
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
            let result = alarmStore.groupIdsForAlarmsWithinTimeRange() // 範囲内に設定したアラームがあるか
            alarmStore.groupIds = result.groupIds
            alarmStore.Sound = result.firstSound ?? "デフォルト_medium.mp3"
            print("groupids:", alarmStore.groupIds)
            if !alarmStore.groupIds.isEmpty {
                alarmStore.showingAlarmLanding = true
                print("音になった")
                print(alarmStore.showingAlarmLanding)
            }
        }
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
