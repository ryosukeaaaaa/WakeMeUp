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
                    ForEach(alarmStore.alarms.indices, id: \.self) { index in
                        let alarm = alarmStore.alarms[index]
                        VStack {
                            HStack {
                                Text(formatTime(alarm.time))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Spacer()
                                
                                Toggle("", isOn: binding(for: alarmStore.alarms[index]))
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
                                selectedIndex = IdentifiableInt(id: index)
                            }
                        }
                    }
                    .onDelete {indexSet in
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
            .sheet(item: $selectedIndex) { selectedItem in
                AlarmSettingView(alarmStore: alarmStore, index: selectedItem.id)
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

//    // アラームのオン/オフをトグルする関数
//    private func toggleAlarm(at index: Int) {
//        if !alarmStore.alarms[index].isOn && alarmStore.hasFourOrMoreActiveAlarms() {
//            activeAlert = .maxAlarms // アラームが4つ以上オンのときの警告
//        } else {
//            alarmStore.alarms[index].isOn.toggle()
//            print("togle2")
//        }
//    }

    private func binding(for alarm: AlarmData) -> Binding<Bool> {        Binding<Bool>(
            get: { alarm.isOn },
            set: { newValue in
                DispatchQueue.main.async {
                    if newValue && alarmStore.activeAlarmsCount() >= 4 && !alarm.isOn {
                        activeAlert = .maxAlarms
                    } else {
                        if let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) {
                            print("binding")
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
                alarmStore.rescheduleAlarm(alarmTime: alarmStore.alarms[index].time, repeatLabel: alarmStore.alarms[index].repeatLabel, isOn: true, soundName: alarmStore.alarms[index].soundName, groupId: alarmStore.alarms[index].groupId, at: index)
                activeAlert = .silentMode
                alarmStore.saveAlarms()
                print("set")
            } else {
                alarmStore.stopAlarm(alarmStore.alarms[index].groupId)
                alarmStore.saveAlarms()
                print("stop")
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

    // リピートラベルの概要を生成する関数
    private func repeatLabelSummary(repeatedLabel: Set<Weekday>) -> String {
        if repeatedLabel.isEmpty {
            return "なし"
        } else {
            let sortedLabels = repeatedLabel.sorted(by: { $0.index < $1.index })
            let abbreviatedLabels = sortedLabels.map { String($0.rawValue.prefix(1)) }
            return abbreviatedLabels.joined(separator: ",")
        }
    }
}
