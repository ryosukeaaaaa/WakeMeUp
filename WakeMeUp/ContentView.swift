import SwiftUI
import UserNotifications
import AVFoundation
import Speech

struct ContentView: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var debugMessage = ""
    
    @State private var isMissionViewActive = false
    @State private var isPermissionGranted = true
    @State private var showNotificationAlert = false
    @State private var showMicrophoneAlert = false
    @State private var showSpeechRecognitionAlert = false
    
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
            .navigationDestination(isPresented: $alarmStore.showingAlarmLanding) {
                AlarmLandingView(alarmStore: alarmStore, groupId: alarmStore.groupIds, isPresented: $alarmStore.showingAlarmLanding)
                        .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                checkNotificationPermission()
                checkMicrophonePermission()
                checkSpeechRecognitionPermission()
            }
            .onChange(of: alarmStore.showingAlarmLanding) {
                print("showingAlarmLanding changed to: \(alarmStore.showingAlarmLanding)")
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    let result = alarmStore.groupIdsForAlarmsWithinTimeRange()
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
            .alert(isPresented: $showNotificationAlert) {
                Alert(
                    title: Text("通知の許可が必要"),
                    message: Text("アラームを有効にするには通知の許可が必要です。設定から通知を許可してください。"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showMicrophoneAlert) {
                Alert(
                    title: Text("マイクの許可が必要"),
                    message: Text("音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showSpeechRecognitionAlert) {
                Alert(
                    title: Text("音声認識の許可が必要"),
                    message: Text("音声認識を有効にするには音声認識の許可が必要です。設定から音声認識を許可してください。"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAlarmLanding"))) { notification in
            let result = alarmStore.groupIdsForAlarmsWithinTimeRange()
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
                    self.showNotificationAlert = true
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
    
    private func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            print("マイクの許可が得られています")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.showMicrophoneAlert = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showMicrophoneAlert = true
            }
        @unknown default:
            DispatchQueue.main.async {
                self.showMicrophoneAlert = true
            }
        }
    }
    
    private func checkSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("音声認識の許可が得られています")
                case .denied, .restricted, .notDetermined:
                    self.showSpeechRecognitionAlert = true
                @unknown default:
                    self.showSpeechRecognitionAlert = true
                }
            }
        }
    }
}

