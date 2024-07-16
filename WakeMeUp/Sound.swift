import SwiftUI

class SoundData: ObservableObject {
    @Published var soundSources: [String] = ["alarmsound", "G"]
}

struct Sound: View {
    @StateObject private var soundData = SoundData()
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var testsound: String
    @State private var volume: String
    
    init(alarmStore: AlarmStore) {
        self.alarmStore = alarmStore
        let (extractedSound, extractedVolume) = Sound.extractSoundAndVolume(from: alarmStore.settingalarm.soundName)
        _testsound = State(initialValue: extractedSound)
        _volume = State(initialValue: extractedVolume)
    }
    
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
                            Text("\(sound)")
                                .onTapGesture {
                                    testsound = sound
                                }
                            Spacer()
                            if testsound == sound {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    HStack {
                        Text("G.mp3")
                            .onTapGesture {
                                alarmStore.settingalarm.soundName = "G_medium.mp3"
                                testsound = "G"
                            }
                        Button(action: {
                            alarmStore.testSound(sound: "G_medium.mp3")
                        }) {
                            Image(systemName: "speaker.2.fill")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        if testsound == "G" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section{
                    Button(action: {
                        alarmStore.stopTestSound()
                        alarmStore.testSound(sound: "\(testsound)_\(volume).wav")
                    }) {
                        Text("テスト再生")
                    }
                    Button(action: {
                        alarmStore.stopTestSound()
                    }) {
                        Text("停止")
                            .foregroundColor(.red)
                    }
                }
            }
            .onDisappear{
                alarmStore.settingalarm.soundName = "\(testsound)_\(volume).wav"
            }
        }
    }
    
    static func extractSoundAndVolume(from soundFileName: String) -> (sound: String, volume: String) {
        let components = soundFileName.split(separator: "_")
        if components.count >= 2 {
            let sound = String(components[0])
            let volumeWithExtension = String(components[1])
            let volume = volumeWithExtension.split(separator: ".")[0] // ".wav"や".mp3"を削除
            return (sound, String(volume))
        } else {
            return (soundFileName, "") // デフォルト値
        }
    }
}
