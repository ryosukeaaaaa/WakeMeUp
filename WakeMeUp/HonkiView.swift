import SwiftUI
import UserNotifications
import AVFoundation

struct HonkiView: View {
    @State private var alarmTime = Date()
    @State private var isAlarmSet = false
    @State private var isPermissionGranted = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isAlarmActive = false
    @State var navigateToAlarmLanding = false

    var body: some View {
        NavigationStack {
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

                Button("アラーム音をテスト") {
                    testPlaySound()
                }
                .padding()
            }
            .onAppear(perform: checkNotificationPermission)
            .navigationDestination(isPresented: $navigateToAlarmLanding) {
                AlarmLandingView(isAlarmActive: $isAlarmActive)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAlarmLanding"))) { _ in
            self.navigateToAlarmLanding = true
        }
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
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm_sound.wav"))
        content.userInfo = ["alarmId": "mainAlarm"]

        let calendar = Calendar.current
        let now = Date()
        
        for n in 0...10 {
            let triggerDate = calendar.date(byAdding: .second, value: 8 * n, to: max(alarmTime, now))!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "AlarmNotification\(n)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("アラーム\(n)の設定に失敗しました: \(error.localizedDescription)")
                } else {
                    print("アラーム\(n)が設定されました: \(triggerDate)")
                }
            }
        }
        
        isAlarmSet = true
        isAlarmActive = true
    }

    private func cancelAlarm() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        isAlarmSet = false
        isAlarmActive = false
        print("アラームがキャンセルされました")
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

struct HonkiView_Previews: PreviewProvider {
    static var previews: some View {
        HonkiView()
    }
}
