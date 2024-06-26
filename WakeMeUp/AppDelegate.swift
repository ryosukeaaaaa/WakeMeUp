import UIKit
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")
        if let alarmId = userInfo["alarmId"] as? String,
           let groupId = userInfo["groupId"] as? String {
            print("AppDelegate: AlarmId found: \(alarmId), GroupId found: \(groupId)")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("ShowAlarmLanding"), object: nil, userInfo: ["alarmId": alarmId, "groupId": groupId])
            }
        } else {
            print("AppDelegate: No alarmId or groupId found in userInfo")
        }
        completionHandler()
    }
    
    func navigateToAlarmLanding(alarmId: String, groupId: String) {
        print("Attempting to navigate to AlarmLandingView with alarmId: \(alarmId) and groupId: \(groupId)")
        NotificationCenter.default.post(name: NSNotification.Name("ShowAlarmLanding"), object: nil, userInfo: ["alarmId": alarmId, "groupId": groupId])
    }
}
