import Foundation

struct AlarmData: Identifiable {
    let id = UUID()
    var time: Date
    var repeatLabel: String
    var mission: String
    var isOn: Bool
}

