import SwiftUI
import AVFoundation
import Alamofire

struct ChatRequest: Encodable {
    let model: String
    let messages: [Message]
}

struct Message: Encodable {
    let role: String
    let content: String
}

struct ChatResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: MessageContent
}

struct MessageContent: Decodable {
    let role: String
    let content: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [String] = []
    let apiKey = Config.apiKey
    let endpoint = "https://api.openai.com/v1/chat/completions"
    private var synthesizer = AVSpeechSynthesizer()
    
    @ObservedObject private var whisperRecognizer = WhisperSpeechRecognizer()
    @Published var isRecording = false
    
    var missionState: MissionState
    
    init(missionState: MissionState) {
        self.missionState = missionState
        whisperRecognizer.delegate = self
    }

    func startListening() {
        isRecording.toggle()
        if isRecording {
            whisperRecognizer.startRecording()
        } else {
            whisperRecognizer.stopRecording()
        }
    }
    
    func stopListening() {
        whisperRecognizer.stopRecording()
        isRecording = false
    }
    
    func sendChatRequest(prompt: String) {
        let messages = [
            Message(role: "system", content: "You are an English teacher who speaks only English."), // AIに役割を与える
            Message(role: "user", content: prompt)
        ]
        
        let chatRequest = ChatRequest(model: "gpt-4o", messages: messages)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        AF.request(endpoint, method: .post, parameters: chatRequest, encoder: JSONParameterEncoder.default, headers: headers).responseDecodable(of: ChatResponse.self) { response in
            switch response.result {
            case .success(let chatResponse):
                if let firstChoice = chatResponse.choices.first {
                    DispatchQueue.main.async {
                        let responseMessage = firstChoice.message.content
                        self.messages.append("Bot: \(responseMessage)")
                        self.speakText(responseMessage)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append("Bot: No response from API.")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.messages.append("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

extension ChatViewModel: WhisperSpeechRecognizerDelegate {
    func didRecognizeSpeech(text: String) {
        DispatchQueue.main.async {
            self.messages.append("User (speech): \(text)")
            self.sendChatRequest(prompt: text)
            
            if text.lowercased().contains(self.missionState.randomEntry.0.lowercased()) {
                self.missionState.clear_mission = true
                print("clear!!!!!")
            }
        }
    }
}

struct GPTView: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var missionState: MissionState
    
    @State private var userInput: String = ""
    
    init(missionState: MissionState) {
        self.missionState = missionState
        self.viewModel = ChatViewModel(missionState: missionState)
    }
    
    var body: some View {
        VStack {
            List(viewModel.messages, id: \.self) { message in
                Text(message)
            }
            
            HStack {
                TextField("Type your message", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    viewModel.messages.append("User: \(userInput)")
                    viewModel.sendChatRequest(prompt: userInput)
                    
                    if userInput.lowercased().contains(missionState.randomEntry.0.lowercased()) {
                        missionState.clear_mission = true
                        print("clear!!!!!")
                    }
                    
                    userInput = ""
                }) {
                    Text("Send")
                }
                .padding()
                
                Button(action: {
                    viewModel.startListening()
                }) {
                    Image(systemName: viewModel.isRecording ? "mic.slash.fill" : "mic.fill")
                }
                .padding()
            }
        }
        .onDisappear {
            missionState.shouldLoadInitialEntry = false // フラグをリセット
        }
    }
}


#Preview {
    GPTView(missionState: MissionState())
}

import AVFoundation

protocol WhisperSpeechRecognizerDelegate: AnyObject {
    func didRecognizeSpeech(text: String)
}

class WhisperSpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    weak var delegate: WhisperSpeechRecognizerDelegate?

    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?
    private var silenceTimer: Timer?
    private let silenceDuration: TimeInterval = 2.0 // 無音と判断するまでの時間
    private let silenceThreshold: Float = -50.0 // 無音と判断する音量レベル（dB）

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // ファイルを作成する
        let audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
        self.audioFileURL = audioFileURL
        do {
            audioFile = try AVAudioFile(forWriting: audioFileURL, settings: recordingFormat.settings)
        } catch {
            print("Failed to create audio file: \(error.localizedDescription)")
            return
        }

        inputNode.removeTap(onBus: 0) // remove previous tap before adding a new one
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Failed to write audio buffer: \(error.localizedDescription)")
            }
            self.checkForSilence(buffer: buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start: \(error.localizedDescription)")
            return
        }

        DispatchQueue.main.async {
            self.transcript = "Say something, I'm listening!"
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        silenceTimer?.invalidate()
        silenceTimer = nil

        // Ensure the audio file was correctly written
        let fileManager = FileManager.default
        if let audioFileURL = audioFileURL, fileManager.fileExists(atPath: audioFileURL.path) {
            print("Audio file created at: \(audioFileURL.path)")
            // Send the file to Whisper API
            sendToWhisper(audioFileURL: audioFileURL)
        } else {
            print("Failed to create audio file.")
        }
    }

    private func checkForSilence(buffer: AVAudioPCMBuffer) {
        let channelData = buffer.floatChannelData?[0]
        let channelDataValueArray = stride(from: 0,
                                           to: Int(buffer.frameLength),
                                           by: buffer.stride).map { channelData![$0] }
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)

        if avgPower < silenceThreshold {
            if silenceTimer == nil {
                silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceDuration, repeats: false) { _ in
                    self.stopRecording()
                }
            }
        } else {
            silenceTimer?.invalidate()
            silenceTimer = nil
        }
    }

    private func sendToWhisper(audioFileURL: URL) {
        let apiKey = Config.apiKey
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let filename = audioFileURL.lastPathComponent
        let mimetype = "audio/wav"

        // Add file data to the raw http request data
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(try! Data(contentsOf: audioFileURL))
        body.append("\r\n")

        // Add model parameter
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        body.append("whisper-1\r\n")

        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(response.statusCode)")
            }

            guard let data = data else {
                print("No data received")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("Response Data: \(responseString ?? "No response string")")

            if let result = try? JSONDecoder().decode(WhisperResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.delegate?.didRecognizeSpeech(text: result.text)
                }
            } else {
                print("Failed to decode response")
            }
        }.resume()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct WhisperResponse: Codable {
    let text: String
}

// Helper extension to append string data to Data objects
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

