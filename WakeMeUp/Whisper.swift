import SwiftUI
import AVFoundation

struct Whisper: View {
    @StateObject private var speechRecognizer = WhisperSpeechRecognizer()
    @State private var isRecording = false

    var body: some View {
        VStack {
            if isRecording {
                Text("Listening...")
                    .font(.largeTitle)
                    .padding()
            } else {
                Text("Tap to start recording")
                    .font(.largeTitle)
                    .padding()
            }

            Button(action: {
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
        }
        .padding()
    }
}

class WhisperSpeechRecognizer: ObservableObject {
    @Published var transcript = ""

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
                    self.transcript = result.text
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

#Preview {
    Whisper()
}

// Helper extension to append string data to Data objects
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

/*
 import SwiftUI
 import AVFoundation

 struct Whisper: View {
     @StateObject private var speechRecognizer = WhisperSpeechRecognizer()
     @State private var isRecording = false

     var body: some View {
         VStack {
             if isRecording {
                 Text("Listening...")
                     .font(.largeTitle)
                     .padding()
             } else {
                 Text("Tap to start recording")
                     .font(.largeTitle)
                     .padding()
             }

             Button(action: {
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
         }
         .padding()
     }
 }

 class WhisperSpeechRecognizer: ObservableObject {
     @Published var transcript = ""

     private var audioEngine = AVAudioEngine()
     private var audioFile: AVAudioFile?
     private var audioFileURL: URL?

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
         inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
             do {
                 try self.audioFile?.write(from: buffer)
             } catch {
                 print("Failed to write audio buffer: \(error.localizedDescription)")
             }
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

         // Stop recording after a delay to ensure we have enough audio data
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Increase delay to 3 seconds
             self.stopRecording()
         }
     }

     func stopRecording() {
         audioEngine.stop()
         audioEngine.inputNode.removeTap(onBus: 0)

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
                     self.transcript = result.text
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

 #Preview {
     Whisper()
 }

 // Helper extension to append string data to Data objects
 extension Data {
     mutating func append(_ string: String) {
         if let data = string.data(using: .utf8) {
             append(data)
         }
     }
 }


*/
