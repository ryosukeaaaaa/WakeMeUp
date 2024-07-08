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
