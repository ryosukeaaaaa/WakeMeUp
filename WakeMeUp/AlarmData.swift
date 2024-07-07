import Foundation
import UserNotifications

struct AlarmData: Identifiable, Codable {
    let id: UUID
    var time: Date
    var repeatLabel: String
    var mission: String
    var isOn: Bool
    var soundName: String
    var snoozeEnabled: Bool
    var groupId: String

    init(id: UUID = UUID(), time: Date, repeatLabel: String, mission: String, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String) {
        self.id = id
        self.time = time
        self.repeatLabel = repeatLabel
        self.mission = mission
        self.isOn = isOn
        self.soundName = soundName
        self.snoozeEnabled = snoozeEnabled
        self.groupId = groupId
    }

    // Codable プロトコルに準拠するためのカスタムデコーダー
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        time = try container.decode(Date.self, forKey: .time)
        repeatLabel = try container.decode(String.self, forKey: .repeatLabel)
        mission = try container.decode(String.self, forKey: .mission)
        isOn = try container.decode(Bool.self, forKey: .isOn)
        soundName = try container.decode(String.self, forKey: .soundName)
        snoozeEnabled = try container.decode(Bool.self, forKey: .snoozeEnabled)
        groupId = try container.decode(String.self, forKey: .groupId)
    }

    // Codable プロトコルに準拠するためのカスタムエンコーダー
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(time, forKey: .time)
        try container.encode(repeatLabel, forKey: .repeatLabel)
        try container.encode(mission, forKey: .mission)
        try container.encode(isOn, forKey: .isOn)
        try container.encode(soundName, forKey: .soundName)
        try container.encode(snoozeEnabled, forKey: .snoozeEnabled)
        try container.encode(groupId, forKey: .groupId)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case repeatLabel
        case mission
        case isOn
        case soundName
        case snoozeEnabled
        case groupId
    }
}

func saveAlarmsToUserDefaults(alarms: [AlarmData]) {
    let encoder = JSONEncoder()
    if let encodedAlarms = try? encoder.encode(alarms) {
        UserDefaults.standard.set(encodedAlarms, forKey: "alarms")
    }
}

func loadAlarmsFromUserDefaults() -> [AlarmData] {
    if let savedAlarms = UserDefaults.standard.object(forKey: "alarms") as? Data {
        let decoder = JSONDecoder()
        if let loadedAlarms = try? decoder.decode([AlarmData].self, from: savedAlarms) {
            return loadedAlarms
        }
    }
    return []
}

var alarms = [AlarmData]()

func scheduleNotification(alarmId: String, groupId: String, soundName: String, snoozeEnabled: Bool) {
    let content = UNMutableNotificationContent()
    content.title = "アラーム"
    content.body = "アラームが発生しました"
    content.userInfo = ["alarmId": alarmId, "groupId": groupId]
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))

    let calendar = Calendar.current
    var targetDate = Date()
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

        let alarmData = AlarmData(time: triggerDate, repeatLabel: "なし", mission: "通知", isOn: true, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId)
        alarms.append(alarmData)
    }

    saveAlarmsToUserDefaults(alarms: alarms)
}
