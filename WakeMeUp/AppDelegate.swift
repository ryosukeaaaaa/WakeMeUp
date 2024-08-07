import SwiftUI
import UIKit
import UserNotifications
import GoogleMobileAds

// 通知をタップした時の動作
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var alarmStore = AlarmStore()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Mobile Ads SDKを初期化する
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // 通知センターのデリゲートを設定
        UNUserNotificationCenter.current().delegate = self
        
        // 通知の許可を要求
        requestNotificationAuthorization()
        
        return true
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知の許可が得られました")
            } else if let error = error {
                print("通知の許可が得られませんでした: \(error.localizedDescription)")
            }
        }
    }
    
    // アプリがフォアグラウンドにある時に通知を受け取った場合の処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // フォアグラウンドでも通知を表示
        print("通知を受け取りました: \(userInfo)")
        // オプショナルバインディングを使用してuserInfoの値をアンラップ
        if let groupId = userInfo["groupId"] as? String {
            NotificationCenter.default.post(name: NSNotification.Name("ShowAlarmLanding"), object: nil, userInfo: ["groupId": groupId])
        } else {
            print("groupIdを取得できませんでした。")
        }
        completionHandler([.banner, .sound, .badge])
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("アプリがキルされました")
    }
}


//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        audioPlayerManager.playSound()
//        completionHandler([.banner, .sound])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        audioPlayerManager.playSound()
//        completionHandler()
//    }
    
    
//    // 通知をタップした時の処理
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        // 通知に応じた処理をここに記述
//        print("通知がタップされました: \(response.notification.request.content.title)")
//        
//       // オプショナルバインディングを使用してuserInfoの値をアンラップ
//       if let groupId = userInfo["groupId"] as? String {
//           NotificationCenter.default.post(name: NSNotification.Name("ShowAlarmLanding"), object: nil, userInfo: ["groupId": groupId])
//       } else {
//           print("groupIdを取得できませんでした。")
//       }
//        
//        print("aaa", self.alarmStore.showingAlarmLanding)
//        completionHandler()
//    }

