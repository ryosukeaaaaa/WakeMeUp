import SwiftUI

struct AlarmSettingView: View {
    let groupId: String
    @ObservedObject var alarmStore: AlarmStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alarmsForGroup: [AlarmData] = []
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var soundName = "alarm_sound.wav"
    @State private var snoozeEnabled = false
    
    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false
    
    init(groupId: String, alarmStore: AlarmStore, repeatLabel: Set<Weekday> = []) {
        self.groupId = groupId
        self._alarmStore = ObservedObject(initialValue: alarmStore)
        self._repeatLabel = State(initialValue: repeatLabel)
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
                DisclosureGroup("サウンド", isExpanded: $isExpanded) {
                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "alarm_sound.wav")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("alarm_sound.wav")
                            .onTapGesture {
                                soundName = "alarm_sound.wav"
                            }
                    }

                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "G.mp3")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("G.mp3")
                            .onTapGesture {
                                soundName = "G.mp3"
                            }
                    }

                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "alarm_sound_small.wav")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("alarm_sound_small.wav")
                            .onTapGesture {
                                soundName = "alarm_sound_small.wav"
                            }
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
                        alarmStore.rescheduleAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, isOn: true, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId)
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
                    self.soundName = firstAlarm.soundName
                    self.snoozeEnabled = firstAlarm.snoozeEnabled
                }
            }
            .onDisappear {
                alarmStore.stopTestSound()
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
            return repeatLabel.map { $0.rawValue }.joined(separator: ", ")
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
