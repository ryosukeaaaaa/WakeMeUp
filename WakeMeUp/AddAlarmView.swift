import SwiftUI
import UserNotifications

// アラームの追加
struct AddAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @StateObject private var soundData = SoundData()
    @State private var snoozeEnabled = false
    @Environment(\.presentationMode) var presentationMode

    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false

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
                } label: {
                    HStack {
                        Text("鳴らす日")
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
            }
            .navigationTitle("アラームの追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.scheduleAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, soundName: soundData.soundName, snoozeEnabled: snoozeEnabled)
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
            .onAppear{
                if self.soundData.soundName.isEmpty {
                    self.soundData.soundName = "default"
                }
            }
            .onDisappear {
                alarmStore.stopTestSound()
                soundData.soundName = ""
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

