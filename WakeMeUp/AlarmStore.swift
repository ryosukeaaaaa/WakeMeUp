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
            print("showingAlarmLanding changed to \(showingAlarmLanding)")
        }
    }
    @Published var groupIds: [String] = []
    
    @Published var Sound: String {
        didSet {
            UserDefaults.standard.set(Sound, forKey: "Sound")
        }
    }
    
    //　アラーム編集用の格納庫
    @Published var settingalarm: AlarmData = AlarmData(time: Date(), repeatLabel: [], mission: "通知", isOn: true, soundName: "デフォルト_medium.mp3",  groupId: "")
    
    init() {
        self.showingAlarmLanding = UserDefaults.standard.bool(forKey: "showingAlarmLanding")
        self.Sound = UserDefaults.standard.string(forKey: "Sound") ?? ""
        
        // アプリ初回起動チェック
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            // 初回起動時にデフォルトのアラームを追加
            let defaultAlarms = [
                AlarmData(time: Date(), repeatLabel: [], mission: "通知", isOn: false, soundName: "デフォルト_medium.mp3", groupId: "")
            ]
            self.alarms.append(contentsOf: defaultAlarms)
            saveAlarms()
            
            // 初回起動済みフラグを設定
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        } else {
            loadAlarms()
        }
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
        cancelAlarmNotifications(groupId: groupId)
        alarms.removeAll { $0.groupId == groupId }
        saveAlarms()
    }
    
    func stopAlarm(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId)
        if let index = alarms.firstIndex(where: { $0.groupId == groupId }) {
            alarms[index].isOn = false
        }
        saveAlarms()
    }
    
    func stopAlarm_All(_ groupIds: [String]) {
        for groupId in groupIds {
            // 各 groupId に対してアラーム通知をキャンセル
            cancelAlarmNotifications(groupId: groupId)
            
            // alarms 配列内で一致する groupId を持つアラームの isOn プロパティを false に設定
            if let index = alarms.firstIndex(where: { $0.groupId == groupId }) {
                if alarms[index].repeatLabel.isEmpty{
                    alarms[index].isOn = false
                }else{
                    rescheduleAlarm(alarmTime: alarms[index].time, repeatLabel: alarms[index].repeatLabel, isOn: true, soundName: alarms[index].soundName, groupId: alarms[index].groupId)
                }
            }
        }
        // すべてのアラームを保存
        saveAlarms()
    }
    
    
    private func cancelAlarmNotifications(groupId: String) {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for n in 0...14 {
            let identifier = "AlarmNotification\(groupId)_\(n)"
            identifiers.append(identifier)
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
    
    func scheduleAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, soundName: String) {
        let groupId = UUID().uuidString
        setAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: true, soundName: soundName, groupId: groupId)
    }
    
    func rescheduleAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, groupId: String, at index: Int? = nil) {
        deleteAlarmsByGroupId(groupId)
        setAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: isOn, soundName: soundName, groupId: groupId, at: index)
    }
    
    func setAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, groupId: String, at index: Int? = nil) {
        let calendar = Calendar.current
        
        print("alarmTime (UTC):", alarmTime)
        var targetDate = alarmTime
        
        // targetDateが現在の日付より前の場合、1日加算
        while targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        print("Initial Target Date:", targetDate)
        
        // targetDateが現在の日付の翌日よりも後の場合
        while targetDate > calendar.date(byAdding: .day, value: 1, to: Date())! {
            targetDate = calendar.date(byAdding: .day, value: -1, to: targetDate)!
        }
        
        // targetDateを日本時間に修正
        let targetDay = calendar.date(byAdding: .hour, value: 9, to: targetDate)!
        
        // 繰り返し処理。repeatLabelに含まれる特定の曜日まで調整
        if !repeatLabel.isEmpty {
            var foundMatchingDay = false
            for dayOffset in 0..<7 {
                if let nextTarget = calendar.date(byAdding: .day, value: dayOffset, to: targetDate),
                   let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: targetDay),
                   let nextWeekday = Weekday.allCases.first(where: { $0.index == calendar.component(.weekday, from: nextDate) }),
                    repeatLabel.contains(nextWeekday){
                    targetDate = nextTarget
                    foundMatchingDay = true
                    print("Matching Target Date:", targetDate)
                    break
                }
            }
            
            if !foundMatchingDay {
                print("No matching weekday found in repeatLabel")
            }
        }
        print("Final Target Date:", targetDate)
        
        let newAlarm = AlarmData(
            id: UUID(),
            time: targetDate,  // 気を付ける+1しないとならない。
            repeatLabel: repeatLabel,
            mission: "通知",
            isOn: isOn,
            soundName: soundName,
            groupId: groupId
        )
        
        addAlarm(newAlarm, at: index)
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]
        
        for n in 0...14 {
            let secondsToAdd = 7 * n
            let nanosecondsToAdd = 300_000_000 * n // 0.5秒（500ミリ秒）をナノ秒に変換
            var dateComponents = DateComponents()
            dateComponents.second = secondsToAdd
            dateComponents.nanosecond = nanosecondsToAdd
            
            let triggerDate = calendar.date(byAdding: dateComponents, to: targetDate)!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // サウンド設定を条件に応じて変更
            if n == 0 || n == 4 || n == 8  || n==12 {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "no.mp3")) // バイブレーションのため
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
    }

    
    func testSound(sound: String) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        
        for n in 0...3 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1 + 7.3 * Double(n), repeats: false)
            // サウンド設定を条件に応じて変更
            if n == 0 || n == 4 || n == 8 || n == 12 {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "no.mp3")) // バイブレーションのため
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
    
    func groupIdsForAlarmsWithinTimeRange() -> (groupIds: [String], firstSound: String?) {
        let currentDate = Date()
        let fiveMinutesAgo = currentDate.addingTimeInterval(-5 * 60) // 現在から5分前
//        let fifteenMinutesAgo = currentDate.addingTimeInterval(-15 * 60)
        print(alarms)
        print("current:", currentDate)

        let matchingAlarms = alarms.filter { alarm in
            alarm.isOn && alarm.time >= fiveMinutesAgo && alarm.time <= currentDate
        }

        let groupIds = matchingAlarms.map { $0.groupId }
        let firstSound = matchingAlarms.first?.soundName
        return (groupIds, firstSound)
    }
    
    //　アラームが4つ以上あるか確認
    func activeAlarmsCount() -> Int {
        return alarms.filter { $0.isOn }.count
    }

    func hasFourOrMoreActiveAlarms() -> Bool {
        return activeAlarmsCount() >= 4
    }
}
