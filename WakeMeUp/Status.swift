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
    @State private var selectedSection: Int = 0
    @State private var isSectionSelectPresented: Bool = false
    @State private var selectedMaterial: String = ""
    @State private var sectionCount: Int = 0

    var body: some View {
        NavigationView {
            NavigationStack {
                VStack(spacing: 10) {
                    Spacer()
                    Button(action: {
                        selectedMaterial = "基礎英単語"
                        sectionCount = 15 // セクション数を設定
                        isSectionSelectPresented = true
                    }) {
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
                    
                    Button(action: {
                        selectedMaterial = "TOEIC英単語"
                        sectionCount = 7 // セクション数を設定
                        isSectionSelectPresented = true
                    }) {
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
                    
                    Button(action: {
                        selectedMaterial = "ビジネス英単語"
                        sectionCount = 9 // セクション数を設定
                        isSectionSelectPresented = true
                    }) {
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
                    
                    Button(action: {
                        selectedMaterial = "学術英単語"
                        sectionCount = 5 // セクション数を設定
                        isSectionSelectPresented = true
                    }) {
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
                    
                    // star.csvから読み込んだWordViewを表示するボタン
                    NavigationLink(destination: StarredWordView()) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("後で復習")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.2, green: 0.8, blue: 0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    VStack(spacing: 1) {
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
                    }
                    
                    Spacer()
                    
                    AdMobView()
                        .frame(width: 450, height: 90)
                }
                .padding()
                .navigationTitle("学習状況")
                .onAppear(perform: loadProgressData)
                .navigationDestination(isPresented: $isSectionSelectPresented) {
                    StatusSectionSelectView(material: selectedMaterial, sectionCount: sectionCount, isPresented: $isSectionSelectPresented, selectedSection: $selectedSection)
                }
            }
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

struct NormalWordView: View {
    let material: String
    let selectedSection: Int
    @State private var entries: [(entry: String, status: Int)] = []
    @State private var errorMessage: String?
    @State private var showSortOptions = false
    @State private var sortOrder: SortOrder = .originalOrder
    @State private var searchQuery = ""
    @State private var lastViewedEntry: String?

    enum SortOrder {
        case originalOrder
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
                    List {
                        ForEach(filteredEntries, id: \.entry) { entry in
                            NavigationLink(
                                destination: DetailView(
                                    material: material,
                                    entry: entry,
                                    entries: entries,
                                    lastViewedEntry: $lastViewedEntry
                                )
                            ) {
                                HStack {
                                    Text(entry.entry)
                                    Spacer()
                                }
                                .background(entry.status != 0 ? Color.green.opacity(0.3) : Color.clear) // ステータスが0でなければ背景色を緑にする
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
                .default(Text("単語帳順")) {
                    sortOrder = .originalOrder
                    loadEntries()
                },
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
    
    //　ステータスファイルがなければ作る
    private func createUserCSVIfNeeded2(material: String) {
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
                        userCSVString += "\(entry),0\n"
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

            let start = selectedSection == 0 ? 0 : 200 * (selectedSection - 1)
            let end = selectedSection == 0 ? csv.rows.count : min(200 * selectedSection, csv.rows.count)

            for row in csv.rows[start..<end] {
                if let entry = row["entry"], let statusString = row["status"], let status = Int(statusString) {
                    loadedEntries.append((entry: entry, status: status))
                }
            }
            entries = loadedEntries
            if sortOrder != .originalOrder {
                sortEntries()
            }
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
        default:
            break
        }
    }
}

// entriesで単語列を渡してるからソートが保持される。entriesをインデックスとして単語をcsvファイルから引っ張ってきてる。
struct DetailView: View {
    var material: String
    var entry: (entry: String, status: Int)
    var entries: [(entry: String, status: Int)]
    @Binding var lastViewedEntry: String?
    @State private var entryDetails: (entry: String, ipa: String, meaning: String, example: String, translated: String) = ("", "", "", "", "")
    @State private var currentIndex: Int = 0
    @State private var isShowingDetails = false
    @State private var starredEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] = []
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                TabView(selection: $currentIndex) {
                    ForEach(0..<entries.count, id: \.self) { index in
                        DetailCardView(entry: entries[index], material: material, starredEntries: $starredEntries)
                            .tag(index)
//                            .offset(x: self.offset)
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        self.offset = value.translation.width
//                                    }
//                                    .onEnded { value in
//                                        if value.translation.width < -geometry.size.width / 2 {
//                                            self.currentIndex = min(self.currentIndex + 1, entries.count - 1)
//                                        } else if value.translation.width > geometry.size.width / 2 {
//                                            self.currentIndex = max(self.currentIndex - 1, 0)
//                                        }
//                                        withAnimation {
//                                            self.offset = 0
//                                        }
//                                    }
//                            )
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            currentIndex = entries.firstIndex(where: { $0.entry == entry.entry }) ?? 0
            lastViewedEntry = entry.entry
            loadEntryDetails()
            loadStarredEntries()
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

    func loadStarredEntries() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")

        do {
            let csv = try CSV<Named>(url: starCSVURL)
            var loadedEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] = []

            for row in csv.rows {
                if let entry = row["entry"],
                   let ipa = row["ipa"],
                   let meaning = row["meaning"],
                   let example = row["example_sentence"],
                   let translated = row["translated_sentence"] {
                    loadedEntries.append((entry: entry, ipa: ipa, meaning: meaning, example: example, translated: translated))
                }
            }
            starredEntries = loadedEntries
        } catch {
            print("Failed to read starred entries: \(error.localizedDescription)")
        }
    }
}

struct StarredWordView: View {
    @State private var entries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] = []
    @State private var selectedEntries: Set<String> = [] // Track selected entries
    @State private var errorMessage: String?
    @State private var showSortOptions = false
    @State private var sortOrder: SortOrder = .alphabetical
    @State private var searchQuery = ""
    @State private var lastViewedEntry: String?
    @State private var isSelecting = false // Track if in selection mode

    enum SortOrder {
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
                    List {
                        ForEach(filteredEntries, id: \.entry) { entry in
                            HStack {
                                if isSelecting {
                                    // Checkbox to select/deselect entry
                                    Button(action: {
                                        toggleSelection(for: entry)
                                    }) {
                                        Image(systemName: selectedEntries.contains(entry.entry) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedEntries.contains(entry.entry) ? .blue : .gray)
                                    }
                                }
                                
                                // Conditionally wrap with NavigationLink
                                if !isSelecting {
                                    NavigationLink(destination: StarredDetailView(entry: entry, entries: $entries, lastViewedEntry: $lastViewedEntry)) {
                                        Text(entry.entry)
                                    }
                                } else {
                                    Text(entry.entry)
                                }
                            }
                        }
                        .onDelete(perform: deleteEntry)
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
            loadEntries()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSortOptions.toggle()
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    isSelecting.toggle()
                    if !isSelecting {
                        selectedEntries.removeAll()
                    }
                }) {
                    Text(isSelecting ? "キャンセル" : "選択")
                }
            }
            if isSelecting {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        deleteSelectedEntries()
                    }) {
                        Text("全て消去")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .actionSheet(isPresented: $showSortOptions) {
            ActionSheet(title: Text("並び替えオプション"), buttons: [
                .default(Text("アルファベット順")) {
                    sortOrder = .alphabetical
                    sortEntries()
                },
                .cancel()
            ])
        }
    }

    var filteredEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] {
        if searchQuery.isEmpty {
            return entries
        } else {
            return entries.filter { $0.entry.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    private func loadEntries() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "ドキュメントディレクトリが見つかりません"
            return
        }
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")

        do {
            let csv = try CSV<Named>(url: starCSVURL)
            var loadedEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] = []

            for row in csv.rows {
                if let entry = row["entry"],
                   let ipa = row["ipa"],
                   let meaning = row["meaning"],
                   let example = row["example_sentence"],
                   let translated = row["translated_sentence"] {
                    loadedEntries.append((entry: entry, ipa: ipa, meaning: meaning, example: example, translated: translated))
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
        case .alphabetical:
            entries.sort(by: { $0.entry < $1.entry })
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            removeStarredEntry(entry)
        }
        entries.remove(atOffsets: offsets)
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

    private func deleteSelectedEntries() {
        for entry in selectedEntries {
            if let index = entries.firstIndex(where: { $0.entry == entry }) {
                removeStarredEntry(entries[index])
                entries.remove(at: index)
            }
        }
        selectedEntries.removeAll()
    }

    private func toggleSelection(for entry: (entry: String, ipa: String, meaning: String, example: String, translated: String)) {
        if selectedEntries.contains(entry.entry) {
            selectedEntries.remove(entry.entry)
        } else {
            selectedEntries.insert(entry.entry)
        }
    }
}


struct StarredDetailView: View {
    var entry: (entry: String, ipa: String, meaning: String, example: String, translated: String)
    @Binding var entries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)]
    @Binding var lastViewedEntry: String?
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                TabView(selection: $currentIndex) {
                    ForEach(0..<entries.count, id: \.self) { index in
                        StarredDetailCardView(entry: entries[index], removeAction: {
                            removeStarredEntry(entries[index])
                            removeEntry(at: index)
                        })
                        .tag(index)
//                        .offset(x: self.offset)
//                        .gesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    self.offset = value.translation.width
//                                }
//                                .onEnded { value in
//                                    if value.translation.width < -geometry.size.width / 2 {
//                                        self.currentIndex = min(self.currentIndex + 1, entries.count - 1)
//                                    } else if value.translation.width > geometry.size.width / 2 {
//                                        self.currentIndex = max(self.currentIndex - 1, 0)
//                                    }
//                                    withAnimation {
//                                        self.offset = 0
//                                    }
//                                }
//                        )
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            currentIndex = entries.firstIndex(where: { $0.entry == entry.entry }) ?? 0
            lastViewedEntry = entry.entry
        }
        .onChange(of: currentIndex) {
            lastViewedEntry = entries[currentIndex].entry
        }
    }

    private func removeEntry(at index: Int) {
        entries.remove(at: index)
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
}

struct DetailCardView: View {
    var entry: (entry: String, status: Int)
    var material: String
    @State private var entryDetails: (entry: String, ipa: String, meaning: String, example: String, translated: String) = ("", "", "", "", "")
    @Binding var starredEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)]
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            Spacer()
            VStack {
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
                
                if starredEntries.contains(where: { $0.entry == entryDetails.entry }) {
                    Text("追加済み")
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                } else {
                    Button(action: {
                        starredEntries.append(entryDetails)
                        saveStarredEntry(entryDetails)
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
            
            Spacer()
            Button(action: {
                speakText(entryDetails.entry)
            }) {
                Text("発音再生")
            }
            .padding()
        }
        .onAppear {
            loadEntryDetails()
//            speakText(entryDetails.entry)
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

    private func saveStarredEntry(_ entry: (String, String, String, String, String)) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")
        
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

    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechRecognizer.speechSynthesizer.speak(utterance)
    }
}

struct StarredDetailCardView: View {
    var entry: (entry: String, ipa: String, meaning: String, example: String, translated: String)
    var removeAction: () -> Void
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(entry.entry)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entry.ipa)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Text(entry.meaning)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entry.example)
                    .italic()
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                Text(entry.translated)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .frame(width: 400, height: 400)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Spacer()
            Button(action: {
                speakText(entry.entry)
            }) {
                Text("音声再生")
            }
            
            Button(action: {
                removeAction()
            }) {
                Text("後で復習から削除")
                    .foregroundColor(.red)
                    .padding()
            }
            .padding()
        }
        .onAppear {
//            speakText(entry.entry)
        }
    }

    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechRecognizer.speechSynthesizer.speak(utterance)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(" 検索", text: $text)
                .padding(7)
                .padding(.horizontal, 15)
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
    StatusView()
}

