import SwiftUI
import UserNotifications
import AVFoundation

@main
struct WakeMeUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Pre_ContentView()
        }
    }
}

//本番はこっち

import SwiftUI

// ContentViewにOnboardingViewを組み込む
struct Pre_ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject var alarmStore = AlarmStore()
    @StateObject var itemState = ItemState()
    @StateObject var missionState = MissionState()
    
    var body: some View {
        if hasSeenOnboarding {
            // 通常のメインビュー
            ContentView()
                .environmentObject(alarmStore)
                .environmentObject(itemState)
                .environmentObject(missionState)
        } else {
            // OnboardingViewを表示
            OnboardingView()
        }
    }
}

