/*
import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ContentView: View {  // この定義が正しいことを確認
    @State private var messages: [Message] = []
    @State private var currentMessage: String = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                }
                                Text(message.text)
                                    .padding()
                                    .background(message.isUser ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                if !message.isUser {
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("メッセージを入力", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    sendMessage()
                }) {
                    Text("送信")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !currentMessage.isEmpty else { return }
        let newMessage = Message(text: currentMessage, isUser: true)
        messages.append(newMessage)
        currentMessage = ""
        
        // Simulate a response from the "AI"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let responseMessage = Message(text: "AIの応答: \(newMessage.text)", isUser: false)
            messages.append(responseMessage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
