import SwiftUI
import UserNotifications
import AVFoundation
import Speech

struct ContentView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false
    @State private var isPermissionGranted = true // 通知設定の確認
    @State private var showAlert = false
    
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack{
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
                    Text("英語演習")
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
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    handleScenePhaseActive()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //画面が引き戻されるエラーが起こった。
                    alarmStore.showingAlarmLanding = true
                }
            }
        }
    }
    
    private func handleScenePhaseActive() {
        let result = alarmStore.groupIdsForAlarmsWithinTimeRange()
        alarmStore.groupIds = result.groupIds
        alarmStore.Sound = result.firstSound ?? "_medデフォルトium.mp3"
        
        if !alarmStore.groupIds.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //画面が引き戻されるエラーが起こった。
                alarmStore.showingAlarmLanding = true
            }
        }
        
        checkPermissions()
    }

    private func checkPermissions() {
        checkNotificationPermission()
        checkMicrophonePermission()
        checkSpeechRecognitionPermission()
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    alertTitle = "[重要]通知の許可が必要"
                    alertMessage = "アラームを有効にするには通知の許可が必要です。設定から通知を許可してください。"
                    showAlert = true
                }
            }
        }
    }

    private func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        alertTitle = "[重要]マイクの許可が必要"
                        alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                        showAlert = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                alertTitle = "[重要]マイクの許可が必要"
                alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                showAlert = true
            }
        @unknown default:
            DispatchQueue.main.async {
                alertTitle = "[重要]マイクの許可が必要"
                alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                showAlert = true
            }
        }
    }

    private func checkSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    break
                case .denied, .restricted, .notDetermined:
                    alertTitle = "[重要]音声認識の許可が必要"
                    alertMessage = "発音判定に音声認識の許可が必要です。設定から音声認識を許可してください。"
                    showAlert = true
                @unknown default:
                    alertTitle = "[重要]音声認識の許可が必要"
                    alertMessage = "発音判定に音声認識の許可が必要です。設定から音声認識を許可してください。"
                    showAlert = true
                }
            }
        }
    }
}
