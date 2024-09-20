import SwiftUI

struct AlarmListView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var showingAddAlarm = false
    @State private var selectedAlarm: AlarmData? = nil  // 型をAlarmData?に変更

    // アラートの種類を管理するための列挙型
    enum ActiveAlert: Identifiable {
        case silentMode, maxAlarms
        
        var id: Int {
            switch self {
            case .silentMode: return 1
            case .maxAlarms: return 2
            }
        }
    }
    
    @State private var activeAlert: ActiveAlert? // 現在アクティブなアラート

    var body: some View {
        VStack {
            NavigationView {
                List {
                    let calendar = Calendar.current
                    // アラームを時間順にソート
                    let sortedAlarms = alarmStore.alarms.sorted { alarm1, alarm2 in
                        let components1 = calendar.dateComponents([.hour, .minute], from: alarm1.time)
                        let components2 = calendar.dateComponents([.hour, .minute], from: alarm2.time)
                        
                        if components1.hour != components2.hour {
                            return components1.hour! < components2.hour!
                        } else {
                            return components1.minute! < components2.minute!
                        }
                    }

                    ForEach(sortedAlarms) { alarm in
                        VStack {
                            HStack {
                                Text(formatTime(alarm.time))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(alarm.isOn ? .primary : .secondary)
                                Spacer()
                                
                                Toggle("", isOn: binding(for: alarm))
                                    .labelsHidden()
                                    .buttonStyle(PlainButtonStyle())
                                    .onTapGesture {} // タップイベントを無効化
                            }
                            HStack {
                                Text("サウンド")
                                Spacer()
                                Text(alarm.soundName.dropLast(4))
                            }
                            .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !alarm.isOn && alarmStore.hasFourOrMoreActiveAlarms() {
                                activeAlert = .maxAlarms // アラームが4つ以上オンのときの警告
                            } else {
                                alarmStore.settingalarm = alarm
                                selectedAlarm = alarm  // selectedAlarmにAlarmDataを代入
                            }
                        }
                    }
                    .onDelete { indexSet in
                        // ソートされたアラームのインデックスを使用して、削除するアラームを特定
                        let alarmsToDelete = indexSet.map { sortedAlarms[$0] }
                        for alarm in alarmsToDelete {
                            alarmStore.deleteAlarmsByGroupId(alarm.groupId)
                        }
                    }
                }
                .navigationTitle("アラーム")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            addNewAlarm()
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
                if let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) {
                    AlarmSettingView(alarmStore: alarmStore, index: index)
                }
            }

            Spacer()
            
            AdMobView()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height * 1/9
                )
            Spacer()
            Spacer()
        }
        // アラートの切り替え
        .alert(item: $activeAlert) { activeAlert in
            switch activeAlert {
            case .silentMode:
                return Alert(
                    title: Text("消音モードはオフになっていますか？"),
                    message: Text("消音モードがオンの場合、サウンドが鳴りません。"),
                    dismissButton: .default(Text("OK"))
                )
            case .maxAlarms:
                return Alert(
                    title: Text("確認"),
                    message: Text("アラームは4つまでしかオンにできません。"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // アラームの時間をフォーマットする関数
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func binding(for alarm: AlarmData) -> Binding<Bool> {
        Binding<Bool>(
            get: { alarm.isOn },
            set: { newValue in
                DispatchQueue.main.async {
                    if newValue && alarmStore.activeAlarmsCount() >= 4 && !alarm.isOn {
                        activeAlert = .maxAlarms
                    } else {
                        if let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) {
                            alarmStore.alarms[index].isOn = newValue
                            handleToggleChange(newValue, for: index)
                        }
                    }
                }
            }
        )
    }

    private func handleToggleChange(_ isOn: Bool, for index: Int) {
        withAnimation {
            if isOn {
                let alarm = alarmStore.alarms[index]
                alarmStore.rescheduleAlarm(alarmTime: alarm.time, repeatLabel: alarm.repeatLabel, isOn: true, soundName: alarm.soundName, groupId: alarm.groupId, at: index)
                activeAlert = .silentMode
                alarmStore.saveAlarms()
            } else {
                alarmStore.stopAlarm(alarmStore.alarms[index].groupId)
                alarmStore.saveAlarms()
            }
        }
    }
    
    // 新しいアラームを追加する関数
    private func addNewAlarm() {
        if alarmStore.hasFourOrMoreActiveAlarms() {
            activeAlert = .maxAlarms // アラームが4つ以上オンのときの警告
        } else {
            alarmStore.settingalarm = AlarmData(time: Date(), repeatLabel: [], mission: "通知", isOn: true, soundName: "デフォルト_medium.mp3", groupId: "")
            showingAddAlarm = true
        }
    }
}

