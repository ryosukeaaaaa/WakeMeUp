import SwiftUI

class SoundData: ObservableObject {
    @Published var soundSources: [String] = ["デフォルト","銅鑼の連打", "mix_29s(1)", "mix_29s(2)", "シンプルなアラーム音(1)", "シンプルなアラーム音(2)", "一斗缶をたたき続ける", "高音ビープアラーム音", "クラシックなアラーム", "マジカル着信音ループ", "デジタル目覚まし時計アラーム音", "明るいアップビート着信音", "鳥のさえずり", "ニワトリ", "オルゴールのチャイム", "森の中の小鳥のさえずり", "爽やかな目覚まし音", "Morning", "情動カタルシス", "2_23_AM", "ふぐふぐ体操", "野良猫は宇宙を目指した", "聴いたら分かる目覚めたときから戦闘態勢に入れるやつ", "リコーダービート", "パステルハウス", "はりきっちゃう時のテーマ", "PiPiPiMorning", "CLUB_DEEP_FOG", "追いかけっこキャッハー"]
}

struct Sound: View {
    @StateObject private var soundData = SoundData()
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var testsound: String
    @State private var volume: String
    
    @Environment(\.scenePhase) private var scenePhase
    
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
                    Button(action: {
                        alarmStore.stopTestSound()
                        alarmStore.testSound(sound: "\(testsound)_\(volume).mp3")
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
                // 効果音 Section
                Section(header: Text("効果音")) {
                    ForEach(soundEffects, id: \.self) { sound in
                        HStack {
                            Text("\(sound)")
                            Spacer()
                            if testsound == sound {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            testsound = sound
                        }
                    }
                }
                
                // 音楽 Section
                Section(header: Text("音楽")) {
                    ForEach(musicSounds, id: \.self) { sound in
                        HStack {
                            Text("\(sound)")
                            Spacer()
                            if testsound == sound {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            testsound = sound
                        }
                    }
                }
            }
            .onDisappear {
                alarmStore.stopTestSound()
                alarmStore.settingalarm.soundName = "\(testsound)_\(volume).mp3"
            }
            .onChange(of: scenePhase) { _ in
                alarmStore.stopTestSound()
            }
        }
    }
    
    // Separate the sound sources into two categories
    private var soundEffects: [String] {
        return soundData.soundSources.prefix(while: { $0 != "Morning" }).map { String($0) }
    }
    
    private var musicSounds: [String] {
        return soundData.soundSources.drop(while: { $0 != "Morning" }).map { String($0) }
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
