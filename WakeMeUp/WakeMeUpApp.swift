import SwiftUI
import UserNotifications
import AVFoundation

@main
struct WakeMeUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var alarmStore = AlarmStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmStore)
        }
    }
}

//本番はこっち

import SwiftUI

// ContentViewにOnboardingViewを組み込む
struct Pre_ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject var alarmStore = AlarmStore()
    var body: some View {
        if hasSeenOnboarding {
            // 通常のメインビュー
            ContentView()
                .environmentObject(alarmStore)
        } else {
            // OnboardingViewを表示
            OnboardingView()
        }
    }
}

