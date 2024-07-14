//import SwiftUI
//import UserNotifications
//import AVFoundation
//
//@main
//struct WakeMeUpApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject var alarmStore = AlarmStore()
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView8()
//                .environmentObject(alarmStore)
//        }
//    }
//}
//
//class AudioPlayerManager: ObservableObject {
//    var player: AVAudioPlayer?
//
//    func setupAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
//            print("オーディオセッションが設定されました")
//        } catch {
//            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
//        }
//    }
//
//    func playSound() {
//        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "wav") else {
//            print("alarm_sound.wavが見つかりません")
//            return
//        }
//
//        print("ファイルのURL: \(url)")
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            player?.play()
//            print("音声を再生しました")
//        } catch {
//            print("音声の再生に失敗しました: \(error.localizedDescription)")
//        }
//    }
//}
//
//struct ContentView8: View {
//    @StateObject private var audioPlayerManager = AudioPlayerManager()
//
//    var body: some View {
//        VStack {
//            Text("Wake Me Up")
//                .padding()
//            Button(action: {
//                audioPlayerManager.setupAudioSession()
//                audioPlayerManager.playSound()
//            }) {
//                Text("Play Sound")
//            }
//        }
//        .onAppear {
//            audioPlayerManager.setupAudioSession()
//        }
//    }
//}
//
//import SwiftUI
//
//struct ContentView5: View {
//    
//    @Environment(\.scenePhase) private var scenePhase
//    
//    var body: some View {
//        VStack {
//            Text("Hello, world!")
//        }
//        .onChange(of: scenePhase) {
//            if scenePhase == .background {
//                print("バックグラウンド（.background）")
//            }
//            if scenePhase == .active {
//                print("フォアグラウンド（.active）")
//            }
//            if scenePhase == .inactive {
//                print("バックグラウンドorフォアグラウンド直前（.inactive）")
//            }
//        }
//    }
//}

//import SwiftUI
//import UserNotifications
//import AVFoundation
//
//@main
//struct WakeMeUpApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject var alarmStore = AlarmStore()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(alarmStore)
//        }
//    }
//}
//
//class AudioPlayerManager: ObservableObject {
//    var player: AVAudioPlayer?
//
//    init() {
//        setupAudioSession()
//    }
//
//    func setupAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
//            print("オーディオセッションが設定されました")
//        } catch {
//            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
//        }
//    }
//
//    func checkSilentModeAndPlaySound() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(true)
//            let currentRoute = audioSession.currentRoute
//            for output in currentRoute.outputs {
//                if output.portType == .builtInSpeaker {
//                    print("現在マナーモードです")
//                } else {
//                    print("現在マナーモードではありません")
//                }
//                playSound()
//            }
//        } catch {
//            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
//        }
//    }
//
//    func playSound() {
//        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "wav") else {
//            print("alarm_sound.wavが見つかりません")
//            return
//        }
//
//        print("ファイルのURL: \(url)")
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            player?.play()
//            print("音声を再生しました")
//        } catch {
//            print("音声の再生に失敗しました: \(error.localizedDescription)")
//        }
//    }
//}
//
//struct ContentView7: View {
//    @StateObject private var audioPlayerManager = AudioPlayerManager()
//
//    var body: some View {
//        VStack {
//            Text("Wake Me Up")
//                .padding()
//            Button(action: {
//                audioPlayerManager.checkSilentModeAndPlaySound()
//            }) {
//                Text("Play Sound")
//            }
//        }
//        .onAppear {
//            audioPlayerManager.setupAudioSession()
//            audioPlayerManager.checkSilentModeAndPlaySound()
//        }
//    }
//}
