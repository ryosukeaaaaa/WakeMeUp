import Foundation
import Combine

import SwiftUI
import UserNotifications

// AlarmStore クラスの定義
class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []
    @Published var showingAlarmLanding: Bool {
        didSet {
            UserDefaults.standard.set(showingAlarmLanding, forKey: "showingAlarmLanding")
        }
    }
    @Published var groupIds: [String] = []
//    {
//        didSet {
//            UserDefaults.standard.set(groupId, forKey: "groupId")
//        }
//    }
    
    init() {
        self.showingAlarmLanding = UserDefaults.standard.bool(forKey: "showingAlarmLanding")
        //self.groupId = UserDefaults.standard.string(forKey: "groupId") ?? ""
        loadAlarms()
    }
    
    func addAlarm(_ alarm: AlarmData) {
        alarms.append(alarm)
        saveAlarms()
    }

    func deleteAlarmsByGroupId(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId)
        alarms.removeAll { $0.groupId == groupId }
        saveAlarms()
    }
    
    func deleteAlarmsByGroupId_All(_ groupIds: [String]) {
        for groupId in groupIds {
            // 各 groupId に対してアラーム通知をキャンセル
            cancelAlarmNotifications(groupId: groupId)
            
            // alarms 配列内で一致する groupId を持つアラームの isOn プロパティを false に設定
            alarms.removeAll { $0.groupId == groupId }
        }
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
                alarms[index].isOn = false
            }
        }
        // すべてのアラームを保存
        saveAlarms()
    }
    
    private func cancelAlarmNotifications(groupId: String) {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for n in 0...10 {
            let identifier = "AlarmNotification\(groupId)_\(n)"
            identifiers.append(identifier)
        }
//        if snoozeEnabled {
//            for m in 1...3 {
//                let identifier = "AlarmNotification\(groupId)_\(n)_\(m)"
//                identifiers.append(identifier)
//            }
//        }
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
    
    func rescheduleAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String) {
        deleteAlarmsByGroupId(groupId)
        setAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: isOn, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId)
    }
    
    func setAlarm(alarmTime: Date, repeatLabel: Set<Weekday>, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String) {
        let calendar = Calendar.current
        var targetDate = alarmTime
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        let newAlarm = AlarmData(
            id: UUID(),
            time: alarmTime,
            repeatLabel: repeatLabel,
            mission: "通知",
            isOn: isOn,
            soundName: soundName,
            snoozeEnabled: snoozeEnabled,
            groupId: groupId
        )
        
        addAlarm(newAlarm)
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]
        
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
        
        if snoozeEnabled {
            for m in 1...3 {
                let snoozeTriggerDate = calendar.date(byAdding: .minute, value: 5 * m, to: targetDate)!
                for n in 0...10 {
                    let triggerDate = calendar.date(byAdding: .second, value: 8 * n, to: snoozeTriggerDate)!
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(n)_\(m)", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("アラーム\(n)_\(m)の設定に失敗しました: \(error.localizedDescription)")
                        } else {
                            print("アラーム\(n)_\(m)が設定されました: \(triggerDate)")
                        }
                    }
                }
            }
        }
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

        return alarms.filter { alarm in
            alarm.isOn && alarm.time >= fiveMinutesAgo && alarm.time <= currentDate
        }.map { $0.groupId }
    }
}
