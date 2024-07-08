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
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView(alarmStore: alarmStore)
            }
            .sheet(item: $selectedAlarm) { alarm in
                AlarmSettingView(groupId: alarm.groupId, alarmStore: alarmStore)
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

