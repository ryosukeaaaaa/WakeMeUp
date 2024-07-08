import SwiftUI
import UserNotifications

//　アラームの追加
struct AddAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var repeatLabel = "なし"
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var soundName = "alarm_sound.wav"
    @State private var snoozeEnabled = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                DatePicker("アラーム時間", selection: $alarmTime, displayedComponents: .hourAndMinute)
                TextField("音源ファイル名", text: $soundName)
                Toggle("スヌーズを有効にする", isOn: $snoozeEnabled)

                Button(action: {
                    scheduleAlarm()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("アラームを追加")
                }
            }
            .navigationTitle("アラームを追加")
        }
    }

    private func scheduleAlarm() {
        let groupId = UUID().uuidString  // 新しいUUIDを生成
        let newAlarm = AlarmData(time: alarmTime, repeatLabel: "なし", mission: "通知", isOn: true, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId) // アラーム集合をここで追加
        alarmStore.addAlarm(newAlarm)

        let content = UNMutableNotificationContent()  // 通知の内容を定義
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]

        // 現在の日時を取得し、設定されたアラーム時刻が既に過去のものである場合に、アラーム時刻を翌日に変更
        let calendar = Calendar.current
        var targetDate = alarmTime
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }

        for n in 0...10 {
            let triggerDate = calendar.date(byAdding: .second, value: 8 * n, to: targetDate)!  // 8秒間隔でスケジュール
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate) // triggerDateから年、月、日、時、分、秒のコンポーネントを取得
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)  // トリガー日時
            let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(n)", content: content, trigger: trigger) // 指定した日時に一度だけ通知をトリガーするUNCalendarNotificationTriggerを作成
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("アラーム\(n)の設定に失敗しました: \(error.localizedDescription)")
                } else {
                    print("アラーム\(n)が設定されました: \(triggerDate)")
                }
            }
        }
    }
}

