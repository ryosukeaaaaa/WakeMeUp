import SwiftUI

class SoundData: ObservableObject {
    @Published var soundSources: [String] = ["銅鑼の連打-効果音 (mp3cut.net)", "mix_29s (audio-joiner.com) (1)", "シンプルなアラーム音（ピピピピピ…）-効果音 (mp3cut.net)", "シンプルなアラーム音（ピ…ピ…ピ…ピ…）-効果音 (mp3cut.net)", "mix_29s (audio-joiner.com)", "一斗缶をたたき続ける-効果音 (mp3cut.net)", "高音ビープアラーム音-効果音 (mp3cut.net)", "クラシックなアラーム02-効果音 (mp3cut.net)", "マジカル着信音ループ1-効果音 (mp3cut.net)", "デジタル目覚まし時計アラーム音-効果音 (mp3cut.net)", "デジタル目覚まし時計アラーム音-02-効果音 (mp3cut.net)", "明るいアップビート着信音-効果音 (mp3cut.net)", "鳥のさえずり (audio-joiner.com)", "ニワトリ (audio-joiner.com)", "オルゴールのチャイム-効果音 (mp3cut.net)", "森の中の小鳥のさえずり-効果音 (mp3cut.net)", "爽やかな目覚まし音-効果音 (mp3cut.net)", "Morning_2 (mp3cut.net)", "情動カタルシス (mp3cut.net)", "2_23_AM", "ふぐふぐ体操 (mp3cut.net)", "野良猫は宇宙を目指した_2 (mp3cut.net)", "聴いたら分かる目覚めたときから戦闘態勢に入れるやつ (mp3cut.net)", "リコーダービート (mp3cut.net)", "パステルハウス (mp3cut.net)", "はりきっちゃう時のテーマ (mp3cut.net)", "PiPiPiMorning (mp3cut.net)", "CLUB_DEEP_FOG (mp3cut.net)", "追いかけっこキャッハー (mp3cut.net)"]
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
                    ForEach(soundData.soundSources, id: \.self) { sound in
                        HStack {
                            Text("\(sound)")
                            Spacer()
                            if testsound == sound {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle()) // This ensures the HStack takes the full tappable area
                        .onTapGesture {
                            testsound = sound
                        }
                    }
                }
                
                Section{
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
            }
            .onDisappear{
                alarmStore.stopTestSound()
                alarmStore.settingalarm.soundName = "\(testsound)_\(volume).mp3"
            }
            .onChange(of: scenePhase) {
                alarmStore.stopTestSound()
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
