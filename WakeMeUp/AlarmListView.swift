import Foundation
import Combine

import SwiftUI
import UserNotifications

class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []

    init() {
        loadAlarms()
    }

    func addAlarm(_ alarm: AlarmData) {
        alarms.append(alarm)
        saveAlarms()
    }

    func deleteAlarmsByGroupId(_ groupId: String) {
        cancelAlarmNotifications(groupId: groupId)
        alarms.removeAll { $0.groupId == groupId }
        saveAlarms()
    }
    
    private func cancelAlarmNotifications(groupId: String) {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []

        for n in 0...10 {
            let identifier = "AlarmNotification\(groupId)_\(n)"
            identifiers.append(identifier)
        }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    func saveAlarms() {  // アクセスレベルを変更
        let encoder = JSONEncoder()
        if let encodedAlarms = try? encoder.encode(alarms) {
            UserDefaults.standard.set(encodedAlarms, forKey: "alarms")
        }
    }

    private func loadAlarms() {  // このまま private にします
        if let savedAlarms = UserDefaults.standard.object(forKey: "alarms") as? Data {
            let decoder = JSONDecoder()
            if let loadedAlarms = try? decoder.decode([AlarmData].self, from: savedAlarms) {
                alarms = loadedAlarms
            }
        }
    }
}

import SwiftUI

struct AlarmListView: View {
    @ObservedObject var alarmStore: AlarmStore  // AlarmDta必要ないかも
    @State private var showingAddAlarm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(alarmStore.alarms) { alarm in
                    HStack {
                        Text(formatTime(alarm.time))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { alarm.isOn },
                            set: { newValue in
                                if let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) {
                                    alarmStore.alarms[index].isOn = newValue
                                    alarmStore.saveAlarms()
                                }
                            }
                        ))
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
            .sheet(isPresented: $showingAddAlarm) {
                HonkiView(alarmStore: alarmStore) // groupId を渡す
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
