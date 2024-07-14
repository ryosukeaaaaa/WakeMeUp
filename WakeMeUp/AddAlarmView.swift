import SwiftUI
import UserNotifications

// アラームの追加
struct AddAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @State private var alarmTime = Date()
    @State private var repeatLabel: Set<Weekday> = []
    @State private var mission = "通知"
    @State private var isOn = true
    @State private var soundName = "alarm_sound.wav"
    @State private var snoozeEnabled = false
    @Environment(\.presentationMode) var presentationMode

    @State private var isRepeatDaysExpanded = false  // DisclosureGroupの展開状態を管理するState
    @State private var isExpanded: Bool = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("アラーム時間", selection: $alarmTime, displayedComponents: .hourAndMinute)
                
                DisclosureGroup(isExpanded: $isRepeatDaysExpanded) {
                    ForEach(Weekday.allCases) { day in
                        MultipleSelectionRow(day: day, isSelected: repeatLabel.contains(day)) {
                            if repeatLabel.contains(day) {
                                repeatLabel.remove(day)
                            } else {
                                repeatLabel.insert(day)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("鳴らす日")
                        Spacer()
                        Text(repeatLabelSummary())
                            .foregroundColor(.gray)
                    }
                }
                
                DisclosureGroup("サウンド", isExpanded: $isExpanded) {
                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "alarm_sound.wav")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("alarm_sound.wav")
                            .onTapGesture {
                                soundName = "alarm_sound.wav"
                            }
                    }

                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "G.mp3")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("G.mp3")
                            .onTapGesture {
                                soundName = "G.mp3"
                            }
                    }

                    VStack {
                        Button(action: {
                            alarmStore.testSound(sound: "alarm_sound_small.wav")
                        }) {
                            Text("テスト")
                        }
                        .padding(.bottom, 5)
                        Text("alarm_sound_small.wav")
                            .onTapGesture {
                                soundName = "alarm_sound_small.wav"
                            }
                    }
                }
                
                Toggle("スヌーズを有効にする", isOn: $snoozeEnabled)
            }
            .navigationTitle("アラームの追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        alarmStore.scheduleAlarm(alarmTime: alarmTime, repeatLabel: repeatLabel, soundName: soundName, snoozeEnabled: snoozeEnabled)
                        presentationMode.wrappedValue.dismiss()
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
            .onDisappear {
                alarmStore.stopTestSound()
            }
        }
    }

    private func repeatLabelSummary() -> String {
        if repeatLabel.isEmpty {
            return "なし"
        } else {
            return repeatLabel.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}

