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
import SwiftUI
import AVFoundation

class AudioPlayerManager: ObservableObject {
    private var player: AVAudioPlayer?

    @Published var isSilentMode: Bool = false

    func checkSilentMode() {
        guard let soundURL = Bundle.main.url(forResource: "alarm_sound", withExtension: "wav") else {
            isSilentMode = false
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.volume = 1.0
            player?.numberOfLoops = -1

            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)

            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            player?.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.player?.stop()
                if self.isSilentMode == false {
                    self.isSilentMode = true
                }
            }
        } catch {
            isSilentMode = false
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        if let userInfo = notification.userInfo,
           let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
           let type = AVAudioSession.InterruptionType(rawValue: typeValue) {
            if type == .began {
                isSilentMode = true
            } else {
                isSilentMode = false
            }
        }
    }
}


