import Foundation
import Combine

import SwiftUI
import UserNotifications

//　アラームの追加
class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []
    @Published var showingAlarmLanding: Bool {
        didSet {
            UserDefaults.standard.set(showingAlarmLanding, forKey: "showingAlarmLanding")
        }
    }
    @Published var groupId: String {
        didSet {
            UserDefaults.standard.set(groupId, forKey: "groupId")
        }
    }
    
    init() {
        self.showingAlarmLanding = UserDefaults.standard.bool(forKey: "showingAlarmLanding")
        self.groupId = UserDefaults.standard.string(forKey: "groupId") ?? ""  //　なってるアラーム
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
    
    //　アラームを止める。実際には通知を消去してる
    func stopAlarm(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId)
        if let index = alarms.firstIndex(where: { $0.groupId == groupId }) {
            alarms[index].isOn = false
        }
        saveAlarms() // アラームの状態を保存します
    }
    
    private func cancelAlarmNotifications(groupId: String) {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for n in 0...10 {
            let identifier = "AlarmNotification\(groupId)_\(n)"
            identifiers.append(identifier)
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func saveAlarms() {  // アクセスレベルを変更
        let encoder = JSONEncoder()
        if let encodedAlarms = try? encoder.encode(alarms) {
            UserDefaults.standard.set(encodedAlarms, forKey: "alarms")
        }
    }

    private func loadAlarms() {  // このまま private にします
        if let savedAlarms = UserDefaults.standard.object(forKey: "alarms") as? Data {
            let decoder = JSONDecoder()
            if let loadedAlarms = try? decoder.decode([AlarmData].self, from: savedAlarms) {
                alarms = loadedAlarms
            }
        }
    }
    
    // 新しいメソッドを追加
    func getAlarms(byGroupId groupId: String) -> [AlarmData] {
        return alarms.filter { $0.groupId == groupId }
    }
}

