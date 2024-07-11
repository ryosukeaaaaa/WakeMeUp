import SwiftUI
import UserNotifications

@main
struct WakeMeUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var alarmStore = AlarmStore() // ここでインスタンスを作成

    init() {
        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmStore)
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("通知の許可が得られました")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

import SwiftUI

struct ContentView5: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                print("バックグラウンド（.background）")
            }
            if scenePhase == .active {
                print("フォアグラウンド（.active）")
            }
            if scenePhase == .inactive {
                print("バックグラウンドorフォアグラウンド直前（.inactive）")
            }
        }
    }
}
