import Foundation
import UserNotifications

enum Weekday: String, CaseIterable, Codable, Identifiable {
    case sunday = "日曜日"
    case monday = "月曜日"
    case tuesday = "火曜日"
    case wednesday = "水曜日"
    case thursday = "木曜日"
    case friday = "金曜日"
    case saturday = "土曜日"
    
    var id: String { self.rawValue }
    
    var index: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

// データの形状指定とエンコード・デコード
struct AlarmData: Identifiable, Codable {
    let id: UUID
    var time: Date
    var repeatLabel: Set<Weekday>
    var mission: String
    var isOn: Bool
    var soundName: String
    var snoozeEnabled: Bool
    var groupId: String

    init(id: UUID = UUID(), time: Date, repeatLabel: Set<Weekday>, mission: String, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String) {
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
        let repeatLabelArray = try container.decode([Weekday].self, forKey: .repeatLabel)
        repeatLabel = Set(repeatLabelArray)
        mission = try container.decode(String.self, forKey: .mission)
        isOn = try container.decode(Bool.self, forKey: .isOn)
        soundName = try container.decode(String.self, forKey: .soundName)
        snoozeEnabled = try container.decode(Bool.self, forKey: .snoozeEnabled)
        groupId = try container.decode(String.self, forKey: .groupId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(time, forKey: .time)
        try container.encode(Array(repeatLabel), forKey: .repeatLabel)
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
