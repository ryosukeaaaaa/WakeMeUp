import Foundation
import Combine
import SwiftUI
import UserNotifications

struct AlarmListView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var showingAddAlarm = false
    @State private var selectedAlarm: AlarmData? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(alarmStore.alarms) { alarm in
                    VStack{
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
                        Text(alarm.soundName)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedAlarm = alarm
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
        .sheet(item: $selectedAlarm) { alarm in
            AlarmSettingView(groupId: alarm.groupId, alarmStore: alarmStore)
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
            onAlarm(
                alarmTime: alarmStore.alarms[index].time,
                isOn: alarmStore.alarms[index].isOn,
                soundName: alarmStore.alarms[index].soundName,
                snoozeEnabled: alarmStore.alarms[index].snoozeEnabled,
                groupId: alarmStore.alarms[index].groupId,
                alarmStore: alarmStore
            )
        } else {
            alarmStore.stopAlarm(alarmStore.alarms[index].groupId)
        }
    }
    
    // scheduleAlarm関数
    func onAlarm(alarmTime: Date, isOn: Bool, soundName: String, snoozeEnabled: Bool, groupId: String, alarmStore: AlarmStore) {
        alarmStore.deleteAlarmsByGroupId(groupId)
        
        let newAlarm = AlarmData(time: alarmTime, repeatLabel: "なし", mission: "通知", isOn: true, soundName: soundName, snoozeEnabled: snoozeEnabled, groupId: groupId)
        alarmStore.addAlarm(newAlarm)
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "時間です！起きましょう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        content.userInfo = ["alarmId": newAlarm.id.uuidString, "groupId": groupId]
        
        let calendar = Calendar.current
        var targetDate = alarmTime
        if targetDate < Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        for n in 0...10 {
            let triggerDate = calendar.date(byAdding: .second, value: 8 * n, to: targetDate)!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "AlarmNotification\(groupId)_\(n)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("アラーム\(n)の設定に失敗しました: \(error.localizedDescription)")
                } else {
                    print("アラーム\(n)が設定されました: \(triggerDate)")
                }
            }
        }
    }
}

