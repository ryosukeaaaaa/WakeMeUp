import SwiftUI

class SoundData: ObservableObject {
    @Published var soundName: String = ""
    @Published var soundSources: [String] = ["alarm_sound", "G"]
}

import SwiftUI

struct Sound: View {
    @EnvironmentObject var soundData: SoundData
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var volume = "medium"
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("音量", selection: $volume) {
                        Text("大").tag("high")
                        Text("中").tag("medium")
                        Text("小").tag("low")
                    }
                }

                Section {
                    ForEach(soundData.soundSources, id: \.self) { sound in
                        HStack {
                            Text("\(sound)_\(volume).wav")
                                .onTapGesture {
                                    soundData.soundName = "\(sound)_\(volume).wav"
                                }
                            Button(action: {
                                alarmStore.testSound(sound: "\(sound)_\(volume).wav")
                            }) {
                                Image(systemName: "speaker.2.fill")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            if soundData.soundName == "\(sound)_\(volume).wav" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    HStack {
                        Text("G.mp3")
                            .onTapGesture {
                                soundData.soundName = "G_medium.mp3"
                            }
                        Button(action: {
                            alarmStore.testSound(sound: "G_medium.mp3")
                        }) {
                            Image(systemName: "speaker.2.fill")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        if soundData.soundName == "G_medium.mp3" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}
