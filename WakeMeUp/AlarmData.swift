import Foundation

//　アラームの構造を決めてる
struct AlarmData: Identifiable {
    let id = UUID()
    var time: Date
    var repeatLabel: String
    var mission: String
    var isOn: Bool
}
