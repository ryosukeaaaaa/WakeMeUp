import SwiftUI
import UserNotifications
import AVFoundation

struct HonkiView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var isAlarmSet = false
    @State private var isPermissionGranted = false
    @State private var audioPlayer: AVAudioPlayer?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                DatePicker("アラーム時間", selection: $alarmTime, displayedComponents: .hourAndMinute)
                
                Button(action: {
                    scheduleAlarm()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("アラームを追加")
                }

                Button("アラーム音をテスト") {
                    testPlaySound()
                }
            }
            .navigationTitle("アラームを追加")
            .onAppear(perform: checkNotificationPermission)
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
                if !self.isPermissionGranted {
                    requestNotificationPermission()
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    print("通知の許可が得られました")
                } else {
                    print("通知の許可が得られませんでした")
                }
            }
        }
    }

    private func scheduleAlarm() {
        let groupId = UUID().uuidString
        let newAlarm = Alarm(time: alarmTime, isOn: true, groupId: groupId)
        alarmStore.addAlarm(newAlarm)
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.wav"))
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]

        let calendar = Calendar.current
        var targetDate = alarmTime
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        for n in 0...10 {
            let triggerDate = calendar.date(byAdding: .second, value: 8 * n, to: targetDate)!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(n)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("アラーム\(n)の設定に失敗しました: \(error.localizedDescription)")
                } else {
                    print("アラーム\(n)が設定されました: \(triggerDate)")
                }
            }
        }
        
        isAlarmSet = true
    }

    private func testPlaySound() {
        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "wav") else {
            print("サウンドファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            if let player = audioPlayer {
                if player.play() {
                    print("音声の再生を開始しました")
                } else {
                    print("AVAudioPlayerの再生に失敗しました")
                }
            } else {
                print("AVAudioPlayerの初期化に失敗しました")
            }
        } catch let error as NSError {
            print("音の再生に失敗しました: \(error.localizedDescription)")
            print("エラーコード: \(error.code)")
            print("エラードメイン: \(error.domain)")
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                print("根本的なエラー: \(underlyingError)")
            }
        }
    }
}
