import Foundation
import Combine

import SwiftUI
import UserNotifications

import AVFoundation
// AlarmStore クラスの定義
class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []
    
    @Published var showingAlarmLanding: Bool {
        didSet {
            UserDefaults.standard.set(showingAlarmLanding, forKey: "showingAlarmLanding")
        }
    }
    @Published var groupIds: [String] = []
    
    
    //　アラーム編集用の格納庫
    @Published var settingalarm: AlarmData = AlarmData(time: Date(), repeatLabel: [], mission: "通知", isOn: true, soundName: "default", snoozeEnabled: false, groupId: "")
    
    init() {
        self.showingAlarmLanding = UserDefaults.standard.bool(forKey: "showingAlarmLanding")
        //self.groupId = UserDefaults.standard.string(forKey: "groupId") ?? ""
        loadAlarms()
    }
    
    func addAlarm(_ alarm: AlarmData, at index: Int? = nil) {
        if let index = index, index >= 0, index <= alarms.count {
            alarms.insert(alarm, at: index)
        } else {
            alarms.append(alarm)
        }
        print("alarms:",alarms)
        saveAlarms()
    }

    func deleteAlarmsByGroupId(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId, snoozeEnabled: isSnoozeEnabled(groupId: groupId))
        alarms.removeAll { $0.groupId == groupId }
        saveAlarms()
    }
    
    func stopAlarm(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId, snoozeEnabled: isSnoozeEnabled(groupId: groupId))
        if let index = alarms.firstIndex(where: { $0.groupId == groupId }) {
            alarms[index].isOn = false
        }
        saveAlarms()
    }
    
    func stopAlarm_All(_ groupIds: [String]) {
        for groupId in groupIds {
            // 各 groupId に対してアラーム通知をキャンセル
            cancelAlarmNotifications(groupId: groupId, snoozeEnabled: isSnoozeEnabled(groupId: groupId))
            
            // alarms 配列内で一致する groupId を持つアラームの isOn プロパティを false に設定
            if let index = alarms.firstIndex(where: { $0.groupId == groupId }) {
                alarms[index].isOn = false
            }
        }
        // すべてのアラームを保存
        saveAlarms()
    }
    
    //スヌーズかどうかをgroupIdから取得
    func isSnoozeEnabled(groupId: String) -> Bool {
        return alarms.first(where: { $0.groupId == groupId })?.snoozeEnabled ?? false
    }
    
    private func cancelAlarmNotifications(groupId: String, snoozeEnabled: Bool) {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for n in 0...11 {
            let identifier = "AlarmNotification\(groupId)_\(n)"
            identifiers.append(identifier)
        }
        if snoozeEnabled {
            for m in 1...3 {
                for l in 0...11 {
                    let identifier = "AlarmNotification\(groupId)_\(l)_\(m)"
                    identifiers.append(identifier)
                }
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func saveAlarms() {
        let encoder = JSONEncoder()
        if let encodedAlarms = try? encoder.encode(alarms) {
            UserDefaults.standard.set(encodedAlarms, forKey: "alarms")
        }
    }

    func loadAlarms() {
        if let savedAlarms = UserDefaults.standard.object(forKey: "alarms") as? Data {
            let decoder = JSONDecoder()
            if let loadedAlarms = try? decoder.decode([AlarmData].self, from: savedAlarms) {
                alarms = loadedAlarms
            }
        }
    }
    
    func getAlarms(byGroupId groupId: String) -> [AlarmData] {
        return alarms.filter { $0.groupId == groupId }
    }
    
    func scheduleAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, soundName: String, snoozeEnabled: Bool) {
        let groupId = UUID().uuidString
        setAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: true, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId)
    }
    
    func rescheduleAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String, at index: Int? = nil) {
        deleteAlarmsByGroupId(groupId)
        setAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: isOn, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId, at: index)
    }
    
    func setAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String, at index: Int? = nil) {
        let calendar = Calendar.current
        print("alaemtime", alarmTime)
        var targetDate = alarmTime
        print("alarmerror:", targetDate)
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        let newAlarm = AlarmData(
            id: UUID(),
            time: targetDate,  // 気を付ける+1しないとならない。
            repeatLabel: repeatLabel,
            mission: "通知",
            isOn: isOn,
            soundName: soundName,
            snoozeEnabled: snoozeEnabled,
            groupId: groupId
        )
        
        addAlarm(newAlarm, at: index)
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]
        
        for n in 0...11 {
            let secondsToAdd = 7 * n
            let nanosecondsToAdd = 500_000_000  // 0.5秒（500ミリ秒）をナノ秒に変換
            var dateComponents = DateComponents()
            dateComponents.second = secondsToAdd
            dateComponents.nanosecond = nanosecondsToAdd
            
            let triggerDate = calendar.date(byAdding: dateComponents, to: targetDate)!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // サウンド設定を条件に応じて変更
            if n == 0 || n == 4 || n == 8 {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
            } else {
                content.sound = nil
            }
            
            let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(n)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("アラーム\(n)の設定に失敗しました: \(error.localizedDescription)")
                } else {
                    print("アラーム\(n)が設定されました: \(triggerDate)")
                }
            }
        }
        
        if snoozeEnabled {
            for m in 1...5 {
                let snoozeTriggerDate = calendar.date(byAdding: .minute, value: 5 * m, to: targetDate)!
                for l in 0...11 {
                    let secondsToAdd = 7 * l
                    let nanosecondsToAdd = 800_000_000  // 0.5秒（500ミリ秒）をナノ秒に変換
                    var dateComponents = DateComponents()
                    dateComponents.second = secondsToAdd
                    dateComponents.nanosecond = nanosecondsToAdd
                    
                    let triggerDate = calendar.date(byAdding: dateComponents, to: snoozeTriggerDate)!
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: triggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    
                    // サウンド設定を条件に応じて変更
                    if l == 0 || l == 4 || l == 8 {
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
                    } else {
                        content.sound = nil
                    }
                    
                    let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(l)_\(m)", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("アラーム\(l)_\(m)の設定に失敗しました: \(error.localizedDescription)")
                        } else {
                            print("アラーム\(l)_\(m)が設定されました: \(triggerDate)")
                        }
                    }
                }
            }
        }
    }

    
    func testSound(sound: String) {
        let content = UNMutableNotificationContent()
        content.title = "テストアラーム"
        content.body = "これはテスト通知です"
        
        for n in 0...3 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1 + 7.5 * Double(n), repeats: false)
            // サウンド設定を条件に応じて変更
            if n == 0 || n == 4 || n == 8 {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
            } else {
                content.sound = nil
            }
            
            let request = UNNotificationRequest(identifier: "testAlarm_\(n)", content: content, trigger: trigger)
            
            // 通知をスケジュール
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("通知のスケジュールに失敗しました: \(error.localizedDescription)")
                } else {
                    print("通知がスケジュールされました")
                }
            }
        }
    }
    
    func stopTestSound() {
//        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for n in 0...3 {
            let identifier = "testAlarm_\(n)"
            identifiers.append(identifier)
        }
        // スケジュールされた通知をキャンセル
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        print("通知がキャンセルされました")
    }
    
    func getNextWeekday(from date: Date, weekday: Weekday) -> Date {
        let calendar = Calendar.current
        var targetDate = date
        let weekdayIndex = weekday.index
        
        while calendar.component(.weekday, from: targetDate) != weekdayIndex {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        return targetDate
    }
    
    func groupIdsForAlarmsWithinTimeRange() -> [String] {
        let currentDate = Date()
        let fiveMinutesAgo = currentDate.addingTimeInterval(-5 * 60) // 現在から5分前
        print(alarms)
        print("current:", currentDate)
        return alarms.filter { alarm in
            alarm.isOn && alarm.time >= fiveMinutesAgo && alarm.time <= currentDate
        }.map { $0.groupId }
    }
}
