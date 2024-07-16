import SwiftUI

struct AlarmSettingView: View {
    let groupId: String
    var index: Int
    @ObservedObject var alarmStore: AlarmStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alarmsForGroup: [AlarmData] = []
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @StateObject private var soundData = SoundData()
    @State private var snoozeEnabled = false
    
    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false
    
    init(groupId: String, alarmStore: AlarmStore, repeatLabel: Set<Weekday> = [], index: Int) {
        self.groupId = groupId
        self._alarmStore = ObservedObject(initialValue: alarmStore)
        self._repeatLabel = State(initialValue: repeatLabel)
        self.index = index
    }

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
                        Text("繰り返し")
                        Spacer()
                        Text(repeatLabelSummary())
                            .foregroundColor(.gray)
                    }
                }
                
                NavigationLink {
                    Sound(alarmStore: alarmStore).environmentObject(soundData)
                } label: {
                    HStack {
                        Text("サウンド")
                        Spacer()
                        Text(soundData.soundName)
                            .foregroundColor(.gray)
                    }
                }
                
                Toggle("スヌーズを有効にする", isOn: $snoozeEnabled)
                Button(action: {
                    alarmStore.deleteAlarmsByGroupId(groupId)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("アラームを削除")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("アラームの編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.rescheduleAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: true, soundName: soundData.soundName, snoozeEnabled: snoozeEnabled, groupId: groupId, at: index)
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
            .onAppear {
                self.alarmsForGroup = alarmStore.getAlarms(byGroupId: groupId)
                if let firstAlarm = alarmsForGroup.first {
                    self.alarmTime = firstAlarm.time
                    self.repeatLabel = firstAlarm.repeatLabel
                    self.mission = firstAlarm.mission
                    self.isOn = firstAlarm.isOn
                    // soundName が空の場合にのみ設定を行う
                    if self.soundData.soundName.isEmpty {
                        self.soundData.soundName = firstAlarm.soundName
                    }
                    self.snoozeEnabled = firstAlarm.snoozeEnabled
                }
            }
            .onDisappear {
                alarmStore.stopTestSound()
                soundData.soundName = ""
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

struct MultipleSelectionRow: View {
    var day: Weekday
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(day.rawValue)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
