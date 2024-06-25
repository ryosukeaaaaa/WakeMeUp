//
//  WakeMeUpApp.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/06/10.
//

import SwiftUI

@main
struct WakeMeUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            HonkiView()
        }
    }
}

