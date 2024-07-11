import SwiftUI
import UserNotifications

//　アラームの追加
struct AddAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var soundName = "alarm_sound.wav"
    @State private var snoozeEnabled = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState

    var body: some View {
        NavigationView {
            Form {
                DatePicker("アラーム時間", selection: $alarmTime, displayedComponents: .hourAndMinute)
                DisclosureGroup(isExpanded: $isRepeatDaysExpanded) {
                    ForEach(Weekday.allCases) { day in
                        MultipleSelectionRow(day: day, isSelected: repeatLabel.contains(day)) {
                            if repeatLabel.contains(day) {
                                repeatLabel.remove(day)
                            } else {
                                repeatLabel.insert(day)
                            }
                        }
                    }
                }label: {
                    HStack {
                        Text("鳴らす日")
                        Spacer()
                        Text(repeatLabelSummary())
                            .foregroundColor(.gray)
                    }
                }
                Picker("サウンド", selection: $soundName) {
                    Text("alarm_sound.wav").tag("alarm_sound.wav")
                }
                Toggle("スヌーズを有効にする", isOn: $snoozeEnabled)
            }
            .navigationTitle("アラームの追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.scheduleAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, soundName: soundName, snoozeEnabled: snoozeEnabled)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("保存")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("キャンセル")
                    }
                }
            }
        }
    }
    private func repeatLabelSummary() -> String {
        if repeatLabel.isEmpty {
            return "なし"
        } else {
            return repeatLabel.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}
