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
    @State private var userInput: String = ""
    @State private var isTypingVisible: Bool = false

    @State private var translation: CGSize = .zero
    @State private var degree: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ZStack {
                    cardView()
                        .offset(x: translation.width, y: 0)
                        .rotationEffect(.degrees(degree))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if clear_mission {
                                        translation = value.translation
                                        degree = Double(translation.width / 20)
                                    }
                                }
                                .onEnded { value in
                                    if clear_mission {
                                        if abs(value.translation.width) > 100 {
                                            if value.translation.width > 0 {
                                                makeStatus(for: randomEntry.0, num: 100)
                                                loadNextEntry()
                                            } else {
                                                makeStatus(for: randomEntry.0, num: 10)
                                                loadNextEntry()
                                            }
                                        }
                                        translation = .zero
                                        degree = 0.0
                                    }
                                }
                        )
                }
                Spacer()
                
                Button(action: {
                    lastSpokenText = randomEntry.0
                    speakText(lastSpokenText)
                }) {
                    Text("もう一度再生")
                }
                .padding()
                
                if !clear_mission {
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
                                .font(.headline)
                                .padding(10)
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
                    HStack {
                        Text("←不安")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                        
                        Text("完璧→")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                    }
                    Text("スワイプして次のステップへ")
                        .font(.headline)
                        .padding()
                }
            }
            .onAppear {
                loadInitialEntry()
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
    
    private func cardView() -> some View {
        VStack {
            Text(randomEntry.0)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            Text(randomEntry.1)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Text(randomEntry.2)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 50)
            Text(randomEntry.3)
                .italic()
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 1)
            Text(randomEntry.4)
                .fontWeight(.light)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func loadInitialEntry() {
        if lastRandomEntry.isEmpty {
            randomEntry = loadRandomEntry()
            if randomEntry.0 != "Error" {
                lastRandomEntry = "\(randomEntry.0),\(randomEntry.1),\(randomEntry.2),\(randomEntry.3),\(randomEntry.4)"
            }
        } else {
            randomEntry = parseEntry(lastRandomEntry)
            if randomEntry.0 == "Error" || randomEntry.1 == "CSV file not found" {
                randomEntry = loadRandomEntry()
            }
        }
        speakText(randomEntry.0)
    }

    private func loadNextEntry() {
        randomEntry = loadRandomEntry()
        speakText(randomEntry.0)
        clear_mission = false
        userInput = ""
        isTypingVisible = false
    }

    private func checkUserInput() {
        if userInput.lowercased() == randomEntry.0.lowercased() {
            clear_mission = true
            userInput = ""
        }
    }
    
    private func audio_rec(_ audio: String, _ word: String) {
        if !clear_mission {
            if audio.lowercased().contains(word.lowercased()) {
                clear_mission = true
                isRecording = false
                speechRecognizer.stopRecording()
            } else {
                clear_mission = false
            }
        }
    }

    func loadRandomEntry() -> (String, String, String, String, String) {
        guard let csvURL = Bundle.main.url(forResource: "TOEIC", withExtension: "csv") else {
            return ("Error", "CSV file not found", "", "", "")
        }
        
        do {
            let csv = try CSV<Named>(url: csvURL)
            
            createUserCSVIfNeeded(csv: csv)
            
            // ユーザーの学習状況に合わせて出題頻度を変える
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userCSVURL = documentDirectory.appendingPathComponent("user.csv")
            let statuses = readStatuses(from: userCSVURL)
            
            if statuses.isEmpty {
                print("No statuses found.")
                return ("Error", "No statuses found", "", "", "")
            } else {
                let cumulativeProbabilities = calculateInverseProbabilities(for: statuses)
                
                if let randomRowIndex = selectIndexBasedOnCDF(cumulativeProbabilities: cumulativeProbabilities) {
                    print("Selected Index: \(randomRowIndex)")
                    
                    let row = csv.rows[randomRowIndex]
                    
                    if row.isEmpty {
                        return ("No entries found", "", "", "", "")
                    }
                    
                    let entry = row["entry"] ?? "No entry"
                    let ipa = row["ipa"] ?? "No ipa"
                    let meaning = row["meaning"] ?? "No meaning"
                    let example = row["example_sentence"] ?? "No example"
                    let translated = row["translated_sentence"] ?? "No translation"
                    
                    return (entry, ipa, meaning, example, translated)
                } else {
                    print("Failed to select an index.")
                    return ("Error", "Failed to select an index", "", "", "")
                }
            }
        } catch {
            print("Error: \(error)")
            return ("Error", "reading CSV file", "", "", "")
        }
    }
    
    // ユーザーの学習状況を決定
    func makeStatus(for entry: String, num: Int){
        let status = loadStatus(for: entry)
        let updatedStatus = status + num
        saveStatus(for: entry, status: updatedStatus)
    }
    
    func createUserCSVIfNeeded(csv: CSV<Named>) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent("user.csv")
        
        if !FileManager.default.fileExists(atPath: userCSVURL.path) {
            do {
                var userCSVString = "entry,status\n"
                for row in csv.rows {
                    if let entry = row["entry"] {
                        userCSVString += "\(entry),1000000\n"
                    }
                }
                try userCSVString.write(to: userCSVURL, atomically: true, encoding: .utf8)
            } catch {
                print("Error creating user.csv: \(error)")
            }
        }
    }

    func loadStatus(for entry: String) -> Int {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent("user.csv")
        
        do {
            let csv = try CSV<Named>(url: userCSVURL)
            if let row = csv.rows.first(where: { $0["entry"] == entry }), let statusString = row["status"], let status = Int(statusString) {
                return status
            } else {
                return 0
            }
        } catch {
            print("Error loading status: \(error)")
            return 0
        }
    }

    func saveStatus(for entry: String, status: Int) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent("user.csv")
        
        do {
            let csv = try CSV<Named>(url: userCSVURL)
            var rows = csv.rows
            
            if let rowIndex = rows.firstIndex(where: { $0["entry"] == entry }) {
                print("entory:",entry)
                rows[rowIndex]["status"] = String(status)
            } else {
                rows.append(["entry": entry, "status": String(status)])
            }
            
            try writeCSV(header: ["entry", "status"], rows: rows, to: userCSVURL)
        } catch {
            print("Error saving status: \(error)")
        }
    }

    func writeCSV(header: [String], rows: [[String: String]], to url: URL) throws {
        var csvString = header.joined(separator: ",") + "\n"
        for row in rows {
            let rowString = header.map { row[$0] ?? "" }.joined(separator: ",")
            csvString += rowString + "\n"
        }
        
        guard let encodedData = csvString.data(using: .utf8) else {
            throw CSVError.encodingFailed
        }
        
        do {
            try encodedData.write(to: url)
        } catch {
            throw CSVError.fileWriteFailed
        }
    }
    
    enum CSVError: Error {
        case encodingFailed
        case documentDirectoryNotFound
        case fileWriteFailed
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
    
    func readStatuses(from csvURL: URL) -> [Int] {
        do {
            let csv = try CSV<Named>(url: csvURL)
            var statuses: [Int] = []
            
            for row in csv.rows {
                if let statusString = row["status"], let status = Int(statusString) {
                    statuses.append(status)
                }
            }
            
            return statuses
        } catch {
            print("Error loading statuses: \(error)")
            return []
        }
    }

    func calculateInverseProbabilities(for statuses: [Int]) -> [Double] {
        var inverseProbabilities: [Double] = []
        var totalInverseProbability = 0.0

        for status in statuses {
            let inverseProbability = 1.0 / Double(status)
            inverseProbabilities.append(inverseProbability)
            totalInverseProbability += inverseProbability
        }
        print("ステータス：", statuses)
        // 逆数確率を正規化して累積分布関数を作成
        var cumulativeProbabilities: [Double] = []
        var cumulativeSum = 0.0

        for inverseProbability in inverseProbabilities {
            cumulativeSum += inverseProbability / totalInverseProbability
            cumulativeProbabilities.append(cumulativeSum)
        }
        print("確率：", cumulativeProbabilities)
        return cumulativeProbabilities
    }

    func selectIndexBasedOnCDF(cumulativeProbabilities: [Double]) -> Int? {
        let randomValue = Double.random(in: 0..<1)

        for (index, cumulativeProbability) in cumulativeProbabilities.enumerated() {
            if randomValue < cumulativeProbability {
                return index
            }
        }

        return nil
    }
}

#Preview {
    Pre_Mission()
}


