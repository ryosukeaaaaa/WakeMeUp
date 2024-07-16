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

import SwiftUI

struct ContentView7: View {
    @StateObject private var audioPlayerManager = AudioPlayerManager()

    var body: some View {
        VStack {
            Text(audioPlayerManager.isSilentMode ? "サイレントモードです" : "サイレントモードではありません")
                .padding()
            
            Button(action: {
                audioPlayerManager.checkSilentMode()
            }) {
                Text("サイレントモードをチェック")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            audioPlayerManager.checkSilentMode()
        }
    }
}

struct GachaView: View {
    @State private var items = ["🍎", "🍊", "🍌", "🍉", "🍇", "🍓"]
    @State private var selectedItem = ""
    @State private var isShaking = false
    @State private var isItemVisible = false

    var body: some View {
        VStack {
            Spacer()

            Text(selectedItem)
                .font(.system(size: 100))
                .opacity(isItemVisible ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5), value: isItemVisible)

            Spacer()

            Image(systemName: "g.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(isShaking ? 10 : 0))
                .animation(isShaking ? Animation.linear(duration: 0.1).repeatCount(15, autoreverses: true) : .default, value: isShaking)

            Spacer()

            Button(action: {
                startGacha()
            }) {
                Text("コインを投入してガチャを回す")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func startGacha() {
        isShaking = true
        isItemVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isShaking = false
            selectedItem = items.randomElement() ?? ""
            isItemVisible = true
        }
    }
}

