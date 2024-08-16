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
    
    @State private var showSilentModeAlert = false // 消音モード警告用のステート
    @State private var showingAlert = false // アラート表示用のステート

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
                                
                                // トグル付きボタン
                                Button(action: {
                                    toggleAlarm(at: index)
                                }) {
                                    Toggle("", isOn: binding(for: alarmStore.alarms[index]))
                                        .labelsHidden()
                                }
                                .buttonStyle(PlainButtonStyle())
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
                                showingAlert = true
                            } else {
                                alarmStore.settingalarm = alarm
                                selectedIndex = IdentifiableInt(id: index)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let groupId = alarmStore.alarms[index].groupId
                            alarmStore.deleteAlarmsByGroupId(groupId)
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("確認"),
                              message: Text("アラームは4つまでしかオンにできません。"),
                              dismissButton: .default(Text("OK")))
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
                .frame(width: 450, height: 90)
            Spacer()
            Spacer()
        }
        .alert(isPresented: $showSilentModeAlert) {
            Alert(
                title: Text("消音モードはオフになっていますか？"),
                message: Text("消音モードがオンの場合、サウンドが鳴りません。"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // アラームの時間をフォーマットする関数
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    // アラームのオン/オフをトグルする関数
    private func toggleAlarm(at index: Int) {
        if !alarmStore.alarms[index].isOn && alarmStore.hasFourOrMoreActiveAlarms() {
            showingAlert = true
        } else {
            alarmStore.alarms[index].isOn.toggle()
            alarmStore.saveAlarms()
        }
    }

    // トグルバインディングを作成する関数
    private func binding(for alarm: AlarmData) -> Binding<Bool> {
        Binding<Bool>(
            get: { alarm.isOn },
            set: { newValue in
                if newValue && alarmStore.activeAlarmsCount() >= 4 && !alarm.isOn {
                    showingAlert = true
                } else {
                    if let index = alarmStore.alarms.firstIndex(where: { $0.id == alarm.id }) {
                        alarmStore.alarms[index].isOn = newValue
                        alarmStore.saveAlarms()
                    }
                }
            }
        )
    }

    // 新しいアラームを追加する関数
    private func addNewAlarm() {
        if alarmStore.hasFourOrMoreActiveAlarms() {
            showingAlert = true
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

