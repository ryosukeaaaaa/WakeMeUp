import SwiftUI
import SwiftCSV
import AVFoundation

struct Pre_Mission: View {
    @StateObject private var missionState = MissionState() // MissionStateを使用

    @State private var lastSpokenText: String = ""
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
    var volume: Float = MissionState().correctvolume
    
    @Binding var reset: Bool
    
    @State private var labelText: String = ""
    
    // 追加する状態変数
    @State private var idleTimer: Timer?
    @State private var isAlarmPlaying = false
    
    @State private var isSheetPresented: Bool = false
    @State private var sheet: Bool = false
    
    @State private var showCircle = false
    
    @ObservedObject var alarmStore: AlarmStore
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GeometryReader { geometry in
                    VStack {
                        Spacer()

                        ZStack {
                            cardView()
                                .overlay(
                                    Group {
                                        if showCircle && missionState.correctcircle == "あり"{
                                            Circle()
                                                .stroke(Color.red.opacity(0.5), lineWidth: 20) // Donut-shaped ring
                                                .frame(width: 350, height: 350)
                                                .transition(.opacity)
                                        }
                                    }
                                )
                                .offset(x: translation.width, y: 0)
                                .rotationEffect(.degrees(degree))
                                .onChange(of: missionState.clear_mission) {
                                    if missionState.clear_mission {
                                        showCircle = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showCircle = false
                                        }
                                    }
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            resetIdleTimer()
                                            if missionState.clear_mission {
                                                translation = value.translation
                                                degree = Double(translation.width / 20)
                                            }
                                            // degree値に基づいてlabelTextを更新
                                            if degree > 1 {
                                                labelText = "perfect"
                                            } else if degree < -1 {
                                                labelText = "not"
                                            } else {
                                                labelText = ""
                                            }
                                        }
                                        .onEnded { value in
                                            resetIdleTimer()
                                            if missionState.clear_mission {
                                                if abs(value.translation.width) > 120 {
                                                    if value.translation.width > 0 {
                                                        makeStatus(for: missionState.randomEntry.0, num: 1)
                                                        missionState.missionCount += 1
                                                        if material == "基礎英単語"{
                                                            print("mission",missionState.basicCount)
                                                            missionState.basicCount += 1
                                                        }else if material == "TOEIC英単語"{
                                                            missionState.toeicCount += 1
                                                        }else if material == "ビジネス英単語"{
                                                            missionState.businessCount += 1
                                                        }else if material == "学術英単語"{
                                                            missionState.academicCount += 1
                                                        }
                                                        if missionState.missionCount >= missionState.ClearCount && !fromHome {
                                                            navigateToHome = true
                                                        } else {
                                                            loadNextEntry()
                                                            speechRecognizer.transcript = "長押ししながら発音"
                                                            labelText = ""
                                                        }
                                                    } else {
                                                        makeStatus(for: missionState.randomEntry.0, num: 0)
                                                        missionState.missionCount += 1
                                                        if material == "基礎英単語"{
                                                            missionState.basicCount += 1
                                                        }else if material == "TOEIC英単語"{
                                                            missionState.toeicCount += 1
                                                        }else if material == "ビジネス英単語"{
                                                            missionState.businessCount += 1
                                                        }else if material == "学術英単語"{
                                                            missionState.academicCount += 1
                                                        }
                                                        if missionState.missionCount >= missionState.ClearCount && !fromHome {
                                                            navigateToHome = true
                                                        } else {
                                                            loadNextEntry()
                                                            speechRecognizer.transcript = "長押ししながら発音"
                                                            labelText = ""
                                                        }
                                                    }
                                                }
                                                translation = .zero
                                                degree = 0.0
                                            }
                                            // ドラッグ操作が終了したときにlabelTextを空にする
                                            labelText = ""
                                        }
                                )
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.5) // サイズを画面の半分の高さに調整
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.25) // 上半分に位置させる


                        VStack {
                            Spacer().frame(width: 1)
                            Button(action: {
                                resetIdleTimer()
                                lastSpokenText = missionState.randomEntry.0
                                speakText(lastSpokenText)
                            }) {
                                Text("もう一度再生")
                            }
                            .padding()
                            Spacer().frame(width: 1)

                            if !missionState.clear_mission {
                                Circle()
                                    .fill(isRecording ? Color.white : Color.red)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(isRecording ? Color.white : Color.white, lineWidth: 10)
                                            .frame(width: 115, height: 115)
                                    )
                                    .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                    .gesture(
                                        LongPressGesture(minimumDuration: 0.01)
                                            .onChanged { _ in
                                                resetIdleTimer()
                                                if !isRecording {
                                                    isRecording = true
                                                    speechRecognizer.startRecording()
                                                }
                                            }
                                            .sequenced(before: DragGesture(minimumDistance: 0))
                                            .onEnded { value in
                                                resetIdleTimer()
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
                                    .padding()
                                Spacer()
                                ScrollView {
                                    Text(speechRecognizer.transcript)
                                        .frame(maxWidth: .infinity)// 垂直方向のパディングを増やして大きくする
                                        .padding(.horizontal)
                                }
                                .background(Color(.systemBackground)) // オプション: 背景色を設定
                                Button("タイピングで答える"){
                                    sheet.toggle()
                                }
                                .sheet(isPresented: $sheet) {
                                    NavigationStack {
                                        VStack {
                                            HStack {
                                                TextField("入力してください", text: $userInput)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                Button(action: {
                                                    isSheetPresented = false
                                                    resetIdleTimer()
                                                    checkUserInput()
                                                }) {
                                                    Text("送信")
                                                }
                                            }
                                            .padding()
                                        }
                                        .toolbar {
                                            Button("閉じる", role: .cancel){
                                                sheet.toggle()
                                            }
                                        }
                                    }.presentationDetents([.fraction(1/8)])
                                }

                            } else {
                                if labelText == "perfect" {
                                    Text("完璧！")
                                        .font(.headline)
                                        .foregroundColor(Color.green)
                                        .padding()
                                        .background(Color.green.opacity(0.3))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.green, lineWidth: 2)
                                        )
                                } else if labelText == "not" {
                                    Text("もう少し")
                                        .font(.headline)
                                        .foregroundColor(Color.red)
                                        .padding()
                                        .background(Color.red.opacity(0.3))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.red, lineWidth: 2)
                                        )
                                } else {
                                    Text("単語カードを左右にスワイプして次のステップ")
                                        .font(.headline)
                                        .padding()
                                }
                            }
                        }

                        Spacer() // このSpacerを追加してカードを中央に配置
                    }
                }
            }
            .onAppear {
                if reset{
                    missionState.shouldLoadInitialEntry = true
                    reset = false
                    missionState.PastWords = []  // 過去の単語一覧を消去
                }
                if missionState.shouldLoadInitialEntry { // 英会話画面から戻ってきたときに単語が変わらないように
                    print(material)
                    print("ini")
                    loadNextEntry()
                    speechRecognizer.transcript = "長押ししながら発音"
                    missionState.shouldLoadInitialEntry = false
                }else{
                    GPT = false
                }
                if !fromHome { // fromHomeがfalseの場合のみタイマーを開始
                    startIdleTimer()
                }
            }
            .onDisappear {
                if !fromHome{
                    stopIdleTimerAndAlarm()
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    if missionState.missionCount < missionState.ClearCount && !fromHome {
                        alarmStore.stopTestSound()
                    }
                }
                if scenePhase == .background {
                    if missionState.missionCount < missionState.ClearCount && !fromHome {
                        alarmStore.testSound(sound: alarmStore.Sound)
                    }
                    print("バックグラウンド（.background）")
                }
            }
            .onChange(of: speechRecognizer.transcript) {
                if isRecording {
                    audio_rec(speechRecognizer.transcript, missionState.randomEntry.0)
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MissionClear(missionState: missionState, alarmStore: alarmStore)
                    .navigationBarBackButtonHidden(true)
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
                } else {
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
                        print("tap")
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
            
            // 全然ダメ
            if missionState.starredEntries.contains(where: { $0.0 == missionState.randomEntry.0 }) {
                Button(action: {
                    print(missionState.starredEntries)
                    removeStarredEntry(missionState.randomEntry)
                }) {
                    Text("追加済み")
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
            } else {
                Button(action: {
                    missionState.starredEntries.append(missionState.randomEntry)
                    saveStarredEntry(missionState.randomEntry)
                }) {
                    Text("後で復習")
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height * 24/50
        )
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
        if userInput.lowercased().contains(self.missionState.randomEntry.0.lowercased()) {
            missionState.clear_mission = true
            userInput = ""
            playSound()
        }
    }

    private func audio_rec(_ audio: String, _ word: String) {
        if !missionState.clear_mission {
            if audio.lowercased().contains(word.lowercased()) {
                missionState.clear_mission = true
                playSound()
                isRecording = false
                speechRecognizer.stopRecording()
            } else {
                missionState.clear_mission = false
            }
        }
    }

    func loadRandomEntry() -> (String, String, String, String, String) {
        // 英単語読み込み先
        print("aaaaaa" + material)
        guard let csvURL = Bundle.main.url(forResource: material, withExtension: "csv") else {
            return ("Error", "CSV file not found", "", "", "")
        }

        do {
            let csv = try CSV<Named>(url: csvURL)
            createUserCSVIfNeeded(csv: csv)
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")
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
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")
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
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")

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
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")

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
        speechRecognizer.speechSynthesizer.speak(utterance)
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

    private func startIdleTimer() {
        idleTimer?.invalidate()
        print("start")
        idleTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: false) { _ in
            alarmStore.testSound(sound: alarmStore.Sound)
        }
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        print("reset")
        if !fromHome {
            print("reset2")
            idleTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: false) { _ in
                alarmStore.testSound(sound: alarmStore.Sound)
                print("アラーム再開")
            }
        }
        alarmStore.stopTestSound()
    }
    
    private func stopIdleTimerAndAlarm() {
        idleTimer?.invalidate()
        idleTimer = nil
        alarmStore.stopTestSound()
    }
    
    private func saveStarredEntry(_ entry: (String, String, String, String, String)) {
        print("やばいよやばいよ",entry)
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")
        print("やばいね",starCSVURL.path)
        
        var starCSVString = ""
        
        // ファイルが存在しない場合はヘッダー行を追加
        if !FileManager.default.fileExists(atPath: starCSVURL.path) {
            starCSVString += "entry,ipa,meaning,example_sentence,translated_sentence\n"
        }
        
        // エントリーをCSV形式に変換して追加
        starCSVString += "\(entry.0),\(entry.1),\(entry.2),\(entry.3),\(entry.4)\n"
        
        do {
            if let fileHandle = try? FileHandle(forWritingTo: starCSVURL) {
                fileHandle.seekToEndOfFile()
                if let data = starCSVString.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try starCSVString.write(to: starCSVURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error saving starred entry: \(error)")
        }
    }
    
    private func removeStarredEntry(_ entry: (entry: String, ipa: String, meaning: String, example: String, translated: String)) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")

        do {
            let csv = try CSV<Named>(url: starCSVURL)
            let filteredRows = csv.rows.filter { $0["entry"] != entry.entry }

            var updatedCSVString = "entry,ipa,meaning,example_sentence,translated_sentence\n"
            for row in filteredRows {
                let entry = row["entry"] ?? ""
                let ipa = row["ipa"] ?? ""
                let meaning = row["meaning"] ?? ""
                let example = row["example_sentence"] ?? ""
                let translated = row["translated_sentence"] ?? ""
                updatedCSVString += "\(entry),\(ipa),\(meaning),\(example),\(translated)\n"
            }

            try updatedCSVString.write(to: starCSVURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error removing starred entry: \(error)")
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "Answer", withExtension: "mp3") else {
            print("Failed to find the sound file.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume // ここで音量を設定（0.0〜1.0の範囲）
            audioPlayer?.play()
        } catch let error {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

