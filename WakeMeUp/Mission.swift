import Foundation
import Alamofire
import AVFoundation
import SwiftUI

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
                        self.messages.append("Bot: \(firstChoice.message.content)")
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
            }
        }
    }
}

#Preview {
    GPTView()
}
