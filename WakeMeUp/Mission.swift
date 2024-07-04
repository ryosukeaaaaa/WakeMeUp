import SwiftUI
import SwiftCSV
import AVFoundation

struct Pre_Mission: View {
    @StateObject private var missionState = MissionState() // MissionStateを使用

    @State private var lastSpokenText: String = ""
    @State private var synthesizer = AVSpeechSynthesizer()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var userInput: String = ""
    @State private var isTypingVisible: Bool = false
    @State private var translation: CGSize = .zero
    @State private var degree: Double = 0.0
    @State private var navigateToHome = false
    
    @State private var GPT = false
    
    @State private var navigationPath = NavigationPath() //ホーム画面への遷移
    
    var fromHome: Bool = false  // デフォルト値を設定
    
    var material: String = MissionState().material // デフォルト値を設定
    
    @Binding var reset: Bool
    
    @State private var labelText: String = ""
    
    var body: some View {
        NavigationView {  // なぜかStackだと上手くいかない
            VStack {
                Spacer()
                ZStack {
                    cardView()
                        .offset(x: translation.width, y: 0)
                        .rotationEffect(.degrees(degree))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if missionState.clear_mission {
                                        translation = value.translation
                                        degree = Double(translation.width / 20)
                                    }
                                    // Update labelText based on the degree value
                                    if degree > 1 {
                                        labelText = "perfect"
                                    } else if degree < -1 {
                                        labelText = "not"
                                    } else {
                                        labelText = ""
                                    }
                                }
                                .onEnded { value in
                                    if missionState.clear_mission {
                                        if abs(value.translation.width) > 120 {
                                            if value.translation.width > 0 {
                                                makeStatus(for: missionState.randomEntry.0, num: 1)
                                                missionState.missionCount += 1
                                                if missionState.missionCount >= missionState.ClearCount && !fromHome {
                                                    navigateToHome = true
                                                }else{
                                                    loadNextEntry()
                                                    speechRecognizer.transcript = "長押しして話す"
                                                    labelText = ""
                                                }
                                            } else {
                                                makeStatus(for: missionState.randomEntry.0, num: 0)
                                                missionState.missionCount += 1
                                                if missionState.missionCount >= missionState.ClearCount && !fromHome{
                                                    navigateToHome = true
                                                }else{
                                                    loadNextEntry()
                                                    speechRecognizer.transcript = "長押しして話す"
                                                    labelText = ""
                                                }
                                            }
                                        }
                                        translation = .zero
                                        degree = 0.0
                                    }
                                }
                        )
                }
                .frame(width: 400, height: 400) // Fix the size of the ZStack

                Spacer()

                Button(action: {
                    lastSpokenText = missionState.randomEntry.0
                    speakText(lastSpokenText)
                }) {
                    Text("もう一度再生")
                }
                .padding()

                if !missionState.clear_mission {
                    //ボタン切り替え式録音
//                    Button(action: {
//                        isRecording.toggle()
//                        if isRecording {
//                            speechRecognizer.startRecording()
//                        } else {
//                            speechRecognizer.stopRecording()
//                        }
//                    }) {
//                        Text(isRecording ? "Stop" : "Start")
//                            .font(.title)
//                            .padding(15)
//                            .background(isRecording ? Color.red : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
                    
                    Circle()
                        .fill(isRecording ? Color.white : Color.red)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isRecording ? Color.white : Color.white, lineWidth: 5)
                                .frame(width: 60, height: 60)
                        )
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                        .gesture(
                            LongPressGesture(minimumDuration: 0.1)
                                .onChanged { _ in
                                    if !isRecording {
                                        isRecording = true
                                        speechRecognizer.startRecording()
                                    }
                                }
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onEnded { value in
                                    switch value {
                                    case .second(true, _):
                                        if isRecording {
                                            isRecording = false
                                            speechRecognizer.stopRecording()
                                        }
                                    default:
                                        break
                                    }
                                }
                        )

                    ScrollView {
                        Text(speechRecognizer.transcript)
                            .padding()
                    }

                    if isTypingVisible {
                        TextField("入力してください", text: $userInput, onCommit: {
                            checkUserInput()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    }

                    HStack {
                        Button(action: {
                            isTypingVisible.toggle()
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("タイピング")
                                    .font(.headline)
                            }
                            .padding(10)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            GPT = true
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("英会話練習")
                                    .font(.headline)
                            }
                            .padding(10)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $GPT) {
                            GPTView(missionState: missionState)
                        }
                    }
                } else {
                    //                    HStack {
                    //                        Text("←不安")
                    //                            .foregroundColor(.white)
                    //                            .padding()
                    //                            .background(Color.blue)
                    //                            .cornerRadius(10)
                    //                            .frame(maxWidth: .infinity)
                    //
                    //                        Text("完璧→")
                    //                            .foregroundColor(.white)
                    //                            .padding()
                    //                            .background(Color.yellow)
                    //                            .cornerRadius(10)
                    //                            .frame(maxWidth: .infinity)
                    //                    }
                    if labelText == "perfect" {
                        Text("完璧！")
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    } else if labelText == "not" {
                        Text("まだ不安...")
                            .font(.headline)
                            .padding()
                            .background(Color.red.opacity(0.3))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }else{
                        Text("スワイプして次のステップへ")
                            .font(.headline)
                            .padding()
                    }
                }

                Spacer() // Add this Spacer to ensure the card stays in the middle
            }
            .onAppear {
                print("misision")
                if reset{
                    missionState.shouldLoadInitialEntry = true
                    reset = false
                    missionState.PastWords = []  // 過去の単語一覧を消去
                }
                if missionState.shouldLoadInitialEntry { // 英会話画面から戻ってきたときに単語が変わらないように
                    print("ini")
                    loadNextEntry()
                    speechRecognizer.transcript = "長押しして話す"
                    missionState.shouldLoadInitialEntry = false
                }else{
                    GPT = false
                }
            }
            .onChange(of: speechRecognizer.transcript) {
                if isRecording {
                    audio_rec(speechRecognizer.transcript, missionState.randomEntry.0)
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MissionClear(missionState: missionState)
                    .onAppear {
                    navigateToHome = false
                    missionState.missionCount = 0
                    missionState.clear_mission = false
                    missionState.shouldLoadInitialEntry = true
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.fromHome {
                    Text("\(missionState.missionCount+1) 問目")
                    .fontWeight(.light)
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .padding()
                }else{
                    Text("\(missionState.missionCount+1)問目 / \(missionState.ClearCount)問")
                    .fontWeight(.light)
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .padding()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.fromHome {
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Text("終了")
                    }
                }
            }
       }
    }

    private func cardView() -> some View {
        VStack {
            Text(missionState.randomEntry.0)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            Text(missionState.randomEntry.1)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Text(missionState.randomEntry.2)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 50)
            Text(missionState.randomEntry.3)
                .italic()
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 1)
            Text(missionState.randomEntry.4)
                .fontWeight(.light)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .frame(width: 400, height: 400)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func loadNextEntry() {
        missionState.randomEntry = loadRandomEntry()
        speakText(missionState.randomEntry.0)
        missionState.clear_mission = false
        userInput = ""
        isTypingVisible = false
        
        missionState.PastWords.append(["entry": missionState.randomEntry.0, "meaning": missionState.randomEntry.2])
    }

    private func checkUserInput() {
        if userInput.lowercased() == missionState.randomEntry.0.lowercased() {
            missionState.clear_mission = true
            userInput = ""
        }
    }

    private func audio_rec(_ audio: String, _ word: String) {
        if !missionState.clear_mission {
            if audio.lowercased().contains(word.lowercased()) {
                missionState.clear_mission = true
                isRecording = false
                speechRecognizer.stopRecording()
            } else {
                missionState.clear_mission = false
            }
        }
    }

    func loadRandomEntry() -> (String, String, String, String, String) {
        // 英単語読み込み先
        print("aaaaaa"+material)
        guard let csvURL = Bundle.main.url(forResource: material, withExtension: "csv") else {
            return ("Error", "CSV file not found", "", "", "")
        }

        do {
            let csv = try CSV<Named>(url: csvURL)
            createUserCSVIfNeeded(csv: csv)
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userCSVURL = documentDirectory.appendingPathComponent(material+"_status"+".csv")
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

    func makeStatus(for entry: String, num: Int) {
        let status = loadStatus(for: entry)
        let updatedStatus = status + num
        saveStatus(for: entry, status: updatedStatus)
    }

    func createUserCSVIfNeeded(csv: CSV<Named>) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent(material+"_status"+".csv")
        print(userCSVURL.path)

        if !FileManager.default.fileExists(atPath: userCSVURL.path) {
            do {
                var userCSVString = "entry,status\n"
                for row in csv.rows {
                    if let entry = row["entry"] {
                        userCSVString += "\(entry),1\n"
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
        let userCSVURL = documentDirectory.appendingPathComponent(material+"_status"+".csv")

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
        let userCSVURL = documentDirectory.appendingPathComponent(material+"_status"+".csv")

        do {
            let csv = try CSV<Named>(url: userCSVURL)
            var rows = csv.rows

            if let rowIndex = rows.firstIndex(where: { $0["entry"] == entry }) {
                print("entry:", entry)
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

        // 逆数確率を正規化して累積分布関数を作成
        var cumulativeProbabilities: [Double] = []
        var cumulativeSum = 0.0

        for inverseProbability in inverseProbabilities {
            cumulativeSum += inverseProbability / totalInverseProbability
            cumulativeProbabilities.append(cumulativeSum)
        }

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


