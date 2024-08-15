import SwiftUI

struct AlarmSettingView: View {
    var index: Int
    @ObservedObject var alarmStore: AlarmStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alarmsForGroup: [AlarmData] = []
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var snoozeEnabled = false
    
    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false
    
    @State private var showSilentModeAlert = false // State to manage the alert
    
    init(alarmStore: AlarmStore, index: Int) {
        self.index = index
        self._alarmStore = ObservedObject(initialValue: alarmStore)
    }

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
                        Text(alarmStore.settingalarm.soundName.dropLast(4))
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
            .navigationTitle("アラームの編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.rescheduleAlarm(alarmTime: alarmStore.settingalarm.time, repeatLabel: alarmStore.settingalarm.repeatLabel, isOn: true, soundName: alarmStore.settingalarm.soundName, snoozeEnabled: alarmStore.settingalarm.snoozeEnabled, groupId: alarmStore.settingalarm.groupId, at: index)
//                        presentationMode.wrappedValue.dismiss()
                        showSilentModeAlert = true
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
//            .onAppear {
//                if self.soundData.soundName.isEmpty {
//                    self.soundData.soundName = alarm.soundName
//                    alarmStore.alarmTime = alarm.time
//                    alarmStore.repeatLabel = alarm.repeatLabel
//                    alarmStore.mission = firstAlarm.mission
//                    alarmStore.isOn = firstAlarm.isOn
//                    alarmStore.snoozeEnabled = firstAlarm.snoozeEnabled
//                }
//            }
            .onDisappear {
                alarmStore.stopTestSound()
            }
            .alert(isPresented: $showSilentModeAlert) {
                Alert(
                    title: Text("消音モードはオフになっていますか？"),
                    message: Text("消音モードがオンの場合、サウンドが鳴りません。"),
                    dismissButton: .default(Text("OK")){
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    private func repeatLabelSummary() -> String {
        if alarmStore.settingalarm.repeatLabel.isEmpty {
            return "なし"
        } else {
            let sortedLabels = alarmStore.settingalarm.repeatLabel.sorted(by: { $0.index < $1.index })
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
