import SwiftUI
import AVFoundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var speechSynthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var speechSynthesizerDelegate = SpeechSynthesizerDelegate()

    init() {
        speechRecognizer = SFSpeechRecognizer()
        speechSynthesizer.delegate = speechSynthesizerDelegate
        configureAudioSessionForPlaybackAndRecording() // 初期設定は再生と録音用
    }

    private func configureAudioSessionForPlaybackAndRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session for playback and recording successfully set up")
        } catch {
            print("Failed to setup audio session for playback and recording: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        DispatchQueue.main.async {
            self.transcript = "長押ししながら発音"
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true

        inputNode.removeTap(onBus: 0)

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    self.stopRecording()
                }
            }

            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start: \(error.localizedDescription)")
            return
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.volume = 1.0  // 音量を最大に設定
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        print("Speaking: \(text)")

        DispatchQueue.global(qos: .userInitiated).async {
            self.speechSynthesizer.speak(utterance)
        }
    }
}



// AVSpeechSynthesizerDelegateの実装
class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finished speaking: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("Cancelled speaking: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Started speaking: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("Paused speaking: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("Continued speaking: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("Will speak: \(utterance.speechString) from \(characterRange.location) to \(characterRange.location + characterRange.length)")
    }
}

