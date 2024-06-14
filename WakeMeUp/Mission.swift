//
//  Pre_Mission.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/06/11.
//

import SwiftUI
import SwiftCSV
import AVFoundation

struct Pre_Mission: View {
    @State private var randomEntry: (String, String, String, String, String) = ("", "", "", "", "")
    @State private var lastSpokenText: String = ""
    @State private var synthesizer = AVSpeechSynthesizer()
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var clear_mission = false
    
    var body: some View {
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
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    ScrollView {
                        Text(speechRecognizer.transcript)
                            .padding()
                    }
                } else {
                    Button(action: {
                        // 次の単語へ
                        randomEntry = loadRandomEntry()
                        speakText(randomEntry.0)
                        clear_mission = false
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
                randomEntry = loadRandomEntry()
                speakText(randomEntry.0)
            }
            .onChange(of: speechRecognizer.transcript) {
                audio_rec(speechRecognizer.transcript, randomEntry.0)
            }
        }
        
        // 音声認識
        private func audio_rec(_ audio: String, _ text: String) {
            if audio.lowercased() == text.lowercased() {
                print("Correct transcription")
                print(audio)
                print(text)
                clear_mission = true
                isRecording = false // 録音を停止
            } else {
                print("Incorrect transcription")
                clear_mission = false
                print(audio)
                print(text)
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
               let trans = csv.columns?["translated_sentence"] as? [String]{
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
