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

//import AVFoundation
//
//func setupAudioSession() {
//    do {
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.playback, mode: .default, options: [])
//        try audioSession.setActive(true)
//    } catch {
//        print("Failed to set up audio session: \(error)")
//    }
//}
//
//import SwiftUI
//import AVFoundation
//
//@main
//struct MyApp: App {
//    init() {
//        setupAudioSession4()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView4()
//        }
//    }
//}
//
//struct ContentView4: View {
//    let speechSynthesizer = AVSpeechSynthesizer()
//
//    var body: some View {
//        VStack {
//            Button("Play Sound") {
//                DispatchQueue.global(qos: .userInitiated).async {
//                    speak(text: "Hello, world!", synthesizer: speechSynthesizer)
//                }
//            }
//        }
//    }
//}
//
//func setupAudioSession4() {
//    do {
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.playback, mode: .default, options: [])
//        try audioSession.setActive(true)
//        print("Audio session successfully set up")
//    } catch {
//        print("Failed to set up audio session: \(error)")
//    }
//}
//
//class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("Finished speaking: \(utterance.speechString)")
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        print("Cancelled speaking: \(utterance.speechString)")
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        print("Started speaking: \(utterance.speechString)")
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
//        print("Paused speaking: \(utterance.speechString)")
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
//        print("Continued speaking: \(utterance.speechString)")
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        print("Will speak: \(utterance.speechString) from \(characterRange.location) to \(characterRange.location + characterRange.length)")
//    }
//}
//
//let speechSynthesizerDelegate = SpeechSynthesizerDelegate()
//
//func speak(text: String, synthesizer: AVSpeechSynthesizer) {
//    DispatchQueue.main.async {
//        synthesizer.delegate = speechSynthesizerDelegate
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        print("Speaking: \(text)")
//        synthesizer.speak(utterance)
//    }
//}
