import SwiftUI
import UserNotifications

struct Alarm: Identifiable {
    let id = UUID()
    var time: Date
    var isOn: Bool
    var groupId: String
}

class AlarmStore: ObservableObject {
    @Published var alarms: [Alarm] = []
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        offsets.forEach { index in
            let groupId = alarms[index].groupId
            alarms.remove(atOffsets: offsets)
            cancelAlarmNotifications(groupId: groupId)
        }
    }

    func deleteAlarmsByGroupId(_ groupId: String) {
        alarms.removeAll { $0.groupId == groupId }
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
}

struct AlarmListView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var showingAddAlarm = false
    
    var body: some View {
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
                            }
                        }
                    ))
                }
            }
            .onDelete { indexSet in
                alarmStore.deleteAlarm(at: indexSet)
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
            HonkiView(alarmStore: alarmStore)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

