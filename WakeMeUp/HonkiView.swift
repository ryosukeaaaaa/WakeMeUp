import SwiftUI
import UserNotifications
import AVFoundation

struct HonkiView: View {
    @State private var alarmTime = Date()
    @State private var isAlarmSet = false
    @State private var isPermissionGranted = false
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Text("本気アラーム")
                .font(.largeTitle)
                .padding()

            DatePicker("アラーム時間を設定", selection: $alarmTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Button(action: {
                if isAlarmSet {
                    cancelAlarm()
                } else {
                    scheduleAlarm()
                }
            }) {
                Text(isAlarmSet ? "アラームをキャンセル" : "アラームを設定")
                    .padding()
                    .background(isAlarmSet ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(!isPermissionGranted)

            if isAlarmSet {
                Text("設定されたアラーム時間: \(formattedAlarmTime)")
                    .padding()
            }

            if !isPermissionGranted {
                Text("通知の許可が必要です")
                    .foregroundColor(.red)
            }

            Button("テスト通知を送信") {
                testImmediateNotification()
            }
            .padding()

            Button("アラーム音をテスト") {
                testPlaySound()
            }
            .padding()
        }
        .onAppear(perform: checkNotificationPermission)
    }

    private var formattedAlarmTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: alarmTime)
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
        let content = UNMutableNotificationContent()
        content.title = "本気アラーム"
        content.body = "起きる時間です！本気で起きましょう！"
        
        if let soundPath = Bundle.main.path(forResource: "alarm_sound", ofType: "wav") {
            print("サウンドファイルのパス: \(soundPath)")
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.wav"))
        } else {
            print("カスタムサウンドファイルが見つかりません。デフォルトサウンドを使用します。")
            content.sound = UNNotificationSound.default
        }

        print("設定されたサウンド: \(content.sound?.description ?? "None")")

        let components = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("アラームの設定に失敗しました: \(error.localizedDescription)")
                } else {
                    self.isAlarmSet = true
                    print("アラームが設定されました")
                }
            }
        }

        checkPendingNotifications()
    }

    private func cancelAlarm() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isAlarmSet = false
        print("アラームがキャンセルされました")
    }

    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("保留中の通知リクエスト: \(requests)")
            for request in requests {
                print("通知リクエストの詳細:")
                print("- Identifier: \(request.identifier)")
                print("- Title: \(request.content.title)")
                print("- Body: \(request.content.body)")
                print("- Sound: \(request.content.sound?.description ?? "None")")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("- Trigger: \(trigger.dateComponents)")
                }
            }
        }
    }

    private func testImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "テスト通知"
        content.body = "これはテスト通知です"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.wav"))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("テスト通知の設定に失敗しました: \(error.localizedDescription)")
            } else {
                print("テスト通知が5秒後に送信されます")
            }
        }
    }

    private func testPlaySound() {
        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "wav") else {
            print("サウンドファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            if audioPlayer?.play() == false {
                print("AVAudioPlayerの再生に失敗しました")
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

struct HonkiView_Previews: PreviewProvider {
    static var previews: some View {
        HonkiView()
    }
}
