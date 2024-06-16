import SwiftUI
import SwiftCSV
import AVFoundation

struct Pre_Mission: View {
    @AppStorage("lastRandomEntry") private var lastRandomEntry: String = ""
    @State private var randomEntry: (String, String, String, String, String) = ("", "", "", "", "")
    @State private var lastSpokenText: String = ""
    @State private var synthesizer = AVSpeechSynthesizer()
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var clear_mission = false
    @State private var userInput: String = "" // ユーザー入力の状態を管理
    @State private var isTypingVisible: Bool = false // タイピングフィールドの表示を管理
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer() // 上部スペース
                Text(randomEntry.0)
                    .font(.largeTitle)
                    .fontWeight(.bold) // 太字に設定
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10) // 下部に少し余白を追加
                Text(randomEntry.1)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Text(randomEntry.2)
                    .font(.headline)//subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                Text(randomEntry.3)
                    .italic() // イタリック体に設定
                    .font(.headline)//subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)
                Text(randomEntry.4)
                    .fontWeight(.light) // 軽いウェイトに設定
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer() // 下部スペース
                
                Button(action: {
                    lastSpokenText = randomEntry.0
                    speakText(lastSpokenText)
                }) {
                    Text("もう一度再生")
                }
                .padding()
                
                if !clear_mission {
                    Button(action: {
                        // オンオフの切り替え
                        isRecording.toggle()
                        if isRecording {
                            speechRecognizer.startRecording()
                        } else {
                            speechRecognizer.stopRecording()
                        }
                    }) {
                        Text(isRecording ? "Stop" : "Start")
                            .font(.title)
                            .padding(15)
                            .background(isRecording ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    ScrollView {
                        Text(speechRecognizer.transcript)
                            .padding()
                    }
                    
                    if !isTypingVisible {
                        Button(action: {
                            isTypingVisible.toggle()
                        }) {
                            Text("タイピング")
                                .font(.headline) // 小さめのフォントサイズに変更
                                .padding(10) // パディングを小さめに設定
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    
                    if isTypingVisible {
                        TextField("入力してください", text: $userInput, onCommit: {
                            checkUserInput()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    }
                    NavigationLink(destination: GPTView()) {
                        Text("英会話練習")
                            .font(.title)
                            .padding(10)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                } else {
                    Button(action: {
                        // 次の単語へ
                        randomEntry = loadRandomEntry()
                        speakText(randomEntry.0)
                        clear_mission = false
                        userInput = "" // ユーザー入力をリセット
                        isTypingVisible = false // タイピングフィールドを非表示
                    }) {
                        Text("次の単語")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                if lastRandomEntry.isEmpty {
                    randomEntry = loadRandomEntry()
                    lastRandomEntry = "\(randomEntry.0),\(randomEntry.1),\(randomEntry.2),\(randomEntry.3),\(randomEntry.4)"
                } else {
                    randomEntry = parseEntry(lastRandomEntry)
                }
                speakText(randomEntry.0)
            }
            .onChange(of: speechRecognizer.transcript) {
                if isRecording {
                    audio_rec(speechRecognizer.transcript, randomEntry.0)
                }
            }
            .onDisappear {
                lastRandomEntry = "\(randomEntry.0),\(randomEntry.1),\(randomEntry.2),\(randomEntry.3),\(randomEntry.4)"
            }
        }
    }
    
    
    // ユーザー入力のチェック
    private func checkUserInput() {
        if userInput.lowercased() == randomEntry.0.lowercased() {
            clear_mission = true
            userInput = "" // ユーザー入力をリセット
        }
    }
    
    // 音声認識
    private func audio_rec(_ audio: String, _ word: String) {
        if !clear_mission {
            if audio.lowercased().contains(word.lowercased()) {
                print("Correct transcription")
                print(audio)
                print(word)
                clear_mission = true
                isRecording = false // 録音を停止
                speechRecognizer.stopRecording() // 録音を停止
            } else {
                print("Incorrect transcription")
                clear_mission = false
                print(audio)
                print(word)
            }
        }
    }
    
    func loadRandomEntry() -> (String, String, String, String, String) {
        guard let csvURL = Bundle.main.url(forResource: "TOEIC", withExtension: "csv") else {
            print("CSV file not found")
            return ("Error", "CSV file not found", "", "", "")
        }
        
        do {
            let csv = try CSV<Named>(url: csvURL)
            print(type(of: csv))
            if let entries = csv.columns?["entry"] as? [String],
               let ipas = csv.columns?["ipa"] as? [String],
               let meanings = csv.columns?["meaning"] as? [String],
               let examples = csv.columns?["example_sentence"] as? [String],
               let trans = csv.columns?["translated_sentence"] as? [String] {
                let combinedEntries = zip(zip(zip(zip(entries, ipas), meanings), examples), trans).map { ($0.0.0.0, $0.0.0.1, $0.0.1, $0.1, $1) }
                if let randomElement = combinedEntries.randomElement() {
                    return randomElement
                } else {
                    return ("No entries found", "", "", "", "")
                }
            } else {
                return ("No entries found", "", "", "", "")
            }
        } catch {
            print("Error reading CSV file: \(error)")
            return ("Error", "reading CSV file", "", "", "")
        }
    }
    
    func parseEntry(_ entry: String) -> (String, String, String, String, String) {
        let components = entry.split(separator: ",").map { String($0) }
        guard components.count == 5 else {
            return ("Error", "Invalid entry format", "", "", "")
        }
        return (components[0], components[1], components[2], components[3], components[4])
    }
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

#Preview {
    Pre_Mission()
}

