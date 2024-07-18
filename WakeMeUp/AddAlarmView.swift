import SwiftUI
import UserNotifications

// アラームの追加
struct AddAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var snoozeEnabled = false
    @Environment(\.presentationMode) var presentationMode

    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("アラーム時間", selection: $alarmStore.settingalarm.time, displayedComponents: .hourAndMinute)
                DisclosureGroup(isExpanded: $isRepeatDaysExpanded) {
                    ForEach(Weekday.allCases) { day in
                        MultipleSelectionRow(day: day, isSelected: alarmStore.settingalarm.repeatLabel.contains(day)) {
                            if alarmStore.settingalarm.repeatLabel.contains(day) {
                                alarmStore.settingalarm.repeatLabel.remove(day)
                            } else {
                                alarmStore.settingalarm.repeatLabel.insert(day)
                            }
                        }
                    }
                }label: {
                    HStack {
                        Text("繰り返し")
                        Spacer()
                        Text(repeatLabelSummary())
                            .foregroundColor(.gray)
                    }
                }
                
                NavigationLink {
                    Sound(alarmStore: alarmStore)
                } label: {
                    HStack {
                        Text("サウンド")
                        Spacer()
                        Text(alarmStore.settingalarm.soundName)
                            .foregroundColor(.gray)
                    }
                }
                
                Toggle("スヌーズを有効にする", isOn: $alarmStore.settingalarm.snoozeEnabled)
                Button(action: {
                    alarmStore.deleteAlarmsByGroupId(alarmStore.settingalarm.groupId)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("アラームを削除")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("アラームの追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.scheduleAlarm(alarmTime: alarmStore.settingalarm.time, repeatLabel: alarmStore.settingalarm.repeatLabel, soundName: alarmStore.settingalarm.soundName, snoozeEnabled: alarmStore.settingalarm.snoozeEnabled)
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
            .onDisappear {
                alarmStore.stopTestSound()
            }
        }
    }

    private func repeatLabelSummary() -> String {
        if repeatLabel.isEmpty {
            return "なし"
        } else {
            let sortedLabels = repeatLabel.sorted(by: { $0.index < $1.index })
            let abbreviatedLabels = sortedLabels.map { String($0.rawValue.prefix(1)) }
            return abbreviatedLabels.joined(separator: ",")
        }
    }
}

