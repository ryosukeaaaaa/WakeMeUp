/*
 import Foundation
import Alamofire
import AVFoundation
import SwiftUI
import Speech

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
    
    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestSpeechAuthorization()
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    fatalError("Unknown speech recognition authorization status")
                }
            }
        }
    }
    
    func startListening() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create recognition request")
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available")
            return
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.messages.append("User (speech): \(result.bestTranscription.formattedString)")
                    self.sendChatRequest(prompt: result.bestTranscription.formattedString)
                }
            }
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    func sendChatRequest(prompt: String) {
        let messages = [
            Message(role: "system", content: "You are a helpful assistant."),
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

struct GPTView: View {
    @State private var userInput: String = ""
    @ObservedObject var viewModel = ChatViewModel()
    
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
                    userInput = ""
                }) {
                    Text("Send")
                }
                .padding()
                
                Button(action: {
                    viewModel.startListening()
                }) {
                    Image(systemName: "mic.fill")
                }
                .padding()
            }
        }
    }
}

#Preview {
    GPTView()
}
*/
