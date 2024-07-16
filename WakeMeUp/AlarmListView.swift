import SwiftUI

// Identifiableに準拠したラッパー
struct IdentifiableInt: Identifiable {
    var id: Int
}

struct AlarmListView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var showingAddAlarm = false
    @State private var selectedAlarm: AlarmData? = nil
    @State private var selectedIndex: IdentifiableInt? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(alarmStore.alarms.indices, id: \.self) { index in
                    let alarm = alarmStore.alarms[index]
                    VStack {
                        HStack {
                            Text(formatTime(alarm.time))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Toggle("", isOn: binding(for: alarm))
                                    .labelsHidden()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        HStack {
                            Text("サウンド")
                            Spacer()
                            Text(alarm.soundName)
                        }
                        .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        alarmStore.settingalarm = alarm
                        selectedIndex = IdentifiableInt(id: index)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let groupId = alarmStore.alarms[index].groupId
                        alarmStore.deleteAlarmsByGroupId(groupId)
                    }
                }
            }
            .navigationTitle("アラーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAlarm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAlarm) {
            AddAlarmView(alarmStore: alarmStore)
        }
        .sheet(item: $selectedIndex) { selectedItem in
            AlarmSettingView(alarmStore: alarmStore, index: selectedItem.id)
        }
    }

    // アラームの時間をフォーマットする関数
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    // Toggleのバインディングを取得する関数
    private func binding(for alarm: AlarmData) -> Binding<Bool> {
        guard let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) else {
            return .constant(alarm.isOn)
        }

        return Binding(
            get: { alarmStore.alarms[index].isOn },
            set: { newValue in
                alarmStore.alarms[index].isOn = newValue
                alarmStore.saveAlarms()
                handleToggleChange(newValue, for: index)
            }
        )
    }

    // Toggleが変更されたときの処理を行う関数
    private func handleToggleChange(_ isOn: Bool, for index: Int) {
        if isOn {
            alarmStore.rescheduleAlarm(alarmTime: alarmStore.alarms[index].time, repeatLabel: alarmStore.alarms[index].repeatLabel, isOn: true, soundName: alarmStore.alarms[index].soundName, snoozeEnabled: alarmStore.alarms[index].snoozeEnabled, groupId: alarmStore.alarms[index].groupId)
        } else {
            alarmStore.stopAlarm(alarmStore.alarms[index].groupId)
        }
    }
}

