import SwiftUI

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
        alarms.remove(atOffsets: offsets)
    }
    func deleteAlarmsByGroupId(_ groupId: String) {
        alarms.removeAll { $0.groupId == groupId }
    }
}


import SwiftUI

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
            .onDelete(perform: alarmStore.deleteAlarm)
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
