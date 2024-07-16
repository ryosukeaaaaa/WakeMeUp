import SwiftUI
import SwiftCSV
import AVFoundation
import Charts

struct ProgressData: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}

struct StatusView: View {
    @State private var progressData: [ProgressData] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {

                NavigationLink(destination: WordView(material: "基礎英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("基礎英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "TOEIC英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("TOEIC英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "ビジネス英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("ビジネス英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "学術英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("学術英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                VStack(spacing: 1)  {
                    Chart {
                        ForEach(progressData) { data in
                            BarMark(
                                x: .value("Category", data.category),
                                y: .value("Value", data.value)
                            )
                            .foregroundStyle(data.value < 60 ? Color(red: 0.1, green: 0.5, blue: 1.0) : (data.value < 80 ? Color.yellow : Color.green))
                            .annotation(position: .top) {
                                Text("\(Int(data.value))%")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .offset(y: -5)
                            }
                        }
                    }
                    .chartYScale(domain: 0...100)
                    .frame(height: 150)
                    .padding()
                    Text("達成率")
                }
            }
            .padding()
            .navigationTitle("学習状況")
            .onAppear(perform: loadProgressData)
        }
    }
    
    func loadProgressData() {
        let categories = ["基礎英単語", "TOEIC英単語", "ビジネス英単語", "学術英単語"]
        var data: [ProgressData] = []
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for category in categories {
            let userCSVURL = documentDirectory.appendingPathComponent("\(category)_status.csv")
            
            do {
                let csv = try CSV<Named>(url: userCSVURL)
                let total = csv.rows.count
                let completeCount = csv.rows.filter { $0["status"] != "1" }.count
                let progressValue = (Double(completeCount) / Double(total)) * 100
                
                data.append(ProgressData(category: category, value: progressValue))
            } catch {
                print("Failed to read CSV file for \(category): \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async {
            self.progressData = data
        }
    }
}

struct WordView: View {
    let material: String
    @State private var entries: [(entry: String, status: Int)] = []
    @State private var errorMessage: String?
    @State private var showSortOptions = false
    @State private var sortOrder: SortOrder = .statusDescending
    @State private var searchQuery = ""
    @State private var lastViewedEntry: String?

    enum SortOrder {
        case statusDescending
        case statusAscending
        case alphabetical
    }

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                SearchBar(text: $searchQuery)
                    .padding()
                
                ScrollViewReader { proxy in
                    List(filteredEntries, id: \.entry) { entry in
                        NavigationLink(destination: DetailView(material: material, entry: entry, entries: entries, lastViewedEntry: $lastViewedEntry)) {
                            HStack {
                                Text(entry.entry)
                                Spacer()
                                Text("\(entry.status-1)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onAppear {
                        if let lastViewedEntry = lastViewedEntry {
                            DispatchQueue.main.async {
                                proxy.scrollTo(lastViewedEntry, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            createUserCSVIfNeeded2(material: material)
            loadEntries()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(material)
                        .font(.headline)
                    Text("全\(String(entries.count))単語")
                        .font(.subheadline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSortOptions.toggle()
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .actionSheet(isPresented: $showSortOptions) {
            ActionSheet(title: Text("並び替えオプション"), buttons: [
                .default(Text("未習得順")) {
                    sortOrder = .statusAscending
                    sortEntries()
                },
                .default(Text("習得順")) {
                    sortOrder = .statusDescending
                    sortEntries()
                },
                .default(Text("アルファベット順")) {
                    sortOrder = .alphabetical
                    sortEntries()
                },
                .cancel()
            ])
        }
    }
    
    var filteredEntries: [(entry: String, status: Int)] {
        if searchQuery.isEmpty {
            return entries
        } else {
            return entries.filter { $0.entry.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    func createUserCSVIfNeeded2(material: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")
        
        if (!FileManager.default.fileExists(atPath: userCSVURL.path)) {
            guard let csvURL_status = Bundle.main.url(forResource: material, withExtension: "csv") else {
                print("Error: CSVファイルが見つかりません")
                return
            }
            do {
                let csv = try CSV<Named>(url: csvURL_status)
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
    
    private func loadEntries() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "ドキュメントディレクトリが見つかりません"
            return
        }
        let userCSVURL = documentDirectory.appendingPathComponent("\(material)_status.csv")
        
        do {
            let csv = try CSV<Named>(url: userCSVURL)
            var loadedEntries: [(entry: String, status: Int)] = []

            for row in csv.rows {
                if let entry = row["entry"], let statusString = row["status"], let status = Int(statusString) {
                    loadedEntries.append((entry: entry, status: status))
                }
            }
            entries = loadedEntries
            sortEntries()
        } catch {
            errorMessage = "CSVの読み込みエラー: \(error.localizedDescription)"
        }
    }
    
    private func sortEntries() {
        switch sortOrder {
        case .statusDescending:
            entries.sort(by: { $0.status > $1.status })
        case .statusAscending:
            entries.sort(by: { $0.status < $1.status })
        case .alphabetical:
            entries.sort(by: { $0.entry < $1.entry })
        }
    }
}

struct DetailView: View {
    var material: String
    var entry: (entry: String, status: Int)
    var entries: [(entry: String, status: Int)]
    @Binding var lastViewedEntry: String?
    @State private var entryDetails: (entry: String, ipa: String, meaning: String, example: String, translated: String) = ("", "", "", "", "")
    @State private var currentIndex: Int = 0
    @State private var isShowingDetails = false
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<entries.count, id: \.self) { index in
                DetailCardView(entry: entries[index], material: material, synthesizer: synthesizer)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            currentIndex = entries.firstIndex(where: { $0.entry == entry.entry }) ?? 0
            lastViewedEntry = entry.entry
            loadEntryDetails()
        }
        .onChange(of: currentIndex) {
            lastViewedEntry = entries[currentIndex].entry
            loadEntryDetails()
        }
    }
    
    func loadEntryDetails() {
        guard let csvURL = Bundle.main.url(forResource: material, withExtension: "csv") else {
            entryDetails = ("Error", "CSV file not found", "", "", "")
            return
        }

        do {
            let csv = try CSV<Named>(url: csvURL)
            if let row = csv.rows.first(where: { $0["entry"] == entries[currentIndex].entry }) {
                let entry = row["entry"] ?? "No entry"
                let ipa = row["ipa"] ?? "No ipa"
                let meaning = row["meaning"] ?? "No meaning"
                let example = row["example_sentence"] ?? "No example"
                let translated = row["translated_sentence"] ?? "No translation"

                entryDetails = (entry, ipa, meaning, example, translated)
            } else {
                entryDetails = ("Error", "Entry not found", "", "", "")
            }
        } catch {
            entryDetails = ("Error", "reading CSV file", "", "", "")
        }
    }
}

struct DetailCardView: View {
    var entry: (entry: String, status: Int)
    var material: String
    @State private var entryDetails: (entry: String, ipa: String, meaning: String, example: String, translated: String) = ("", "", "", "", "")
    var synthesizer: AVSpeechSynthesizer
    
    var body: some View {
        VStack {
            VStack{
                Text(entryDetails.entry)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entryDetails.ipa)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Text(entryDetails.meaning)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entryDetails.example)
                    .italic()
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entryDetails.translated)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .frame(width: 400, height: 400)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Button(action: {
                speakText(entryDetails.entry)
            }) {
                Text("もう一度再生")
            }
            .padding()
        }
        .onAppear {
            loadEntryDetails()
            speakText(entryDetails.entry)
        }
    }
    
    func loadEntryDetails() {
        guard let csvURL = Bundle.main.url(forResource: material, withExtension: "csv") else {
            entryDetails = ("Error", "CSV file not found", "", "", "")
            return
        }

        do {
            let csv = try CSV<Named>(url: csvURL)
            if let row = csv.rows.first(where: { $0["entry"] == entry.entry }) {
                let entry = row["entry"] ?? "No entry"
                let ipa = row["ipa"] ?? "No ipa"
                let meaning = row["meaning"] ?? "No meaning"
                let example = row["example_sentence"] ?? "No example"
                let translated = row["translated_sentence"] ?? "No translation"

                entryDetails = (entry, ipa, meaning, example, translated)
            } else {
                entryDetails = ("Error", "Entry not found", "", "", "")
            }
        } catch {
            entryDetails = ("Error", "reading CSV file", "", "", "")
        }
    }
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("検索", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    WordView(material: "TOEIC英単語")
}

