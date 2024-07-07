import SwiftUI
import UserNotifications

//@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.notificationHandler)
        }
    }
}

class NotificationHandler: ObservableObject {
    @Published var pendingAlarmId: String?
    @Published var pendingGroupId: String?
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var notificationHandler = NotificationHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // フォアグラウンドで通知を表示するためのオプション
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 通知をタップしたときの処理
        let userInfo = response.notification.request.content.userInfo
        if let alarmId = userInfo["alarmId"] as? String,
           let groupId = userInfo["groupId"] as? String {
            notificationHandler.pendingAlarmId = alarmId
            notificationHandler.pendingGroupId = groupId
        }
        completionHandler()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let alarmId = notificationHandler.pendingAlarmId, let groupId = notificationHandler.pendingGroupId {
            NotificationCenter.default.post(name: NSNotification.Name("ShowAlarmLanding"), object: nil, userInfo: ["alarmId": alarmId, "groupId": groupId])
            notificationHandler.pendingAlarmId = nil
            notificationHandler.pendingGroupId = nil
        }
    }
}

