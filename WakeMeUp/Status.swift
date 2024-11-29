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
                        .frame(height: UIScreen.main.bounds.height * 1/5)
                        Text("<達成度>")
                            .font(.caption) // 小さめのプリセットフォントサイズ
                            .fontWeight(.bold)
                    }
                    
                    AdMobView()
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height * 1/9
                        )
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
                let completeCount = csv.rows.filter { $0["status"] != "0" }.count
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
    @State private var allEntries: [(entry: String, status: Int)] = [] // すべてのエントリ
    @State private var entries: [(entry: String, status: Int)] = [] // 表示用のエントリ
    @State private var errorMessage: String?
    @State private var showSortOptions = false
    @State private var sortOrder: SortOrder = .originalOrder
    @State private var searchQuery = ""
    @State private var lastViewedEntry: String?
    @State private var isSelecting = false
    @State private var selectedEntries: Set<String> = []

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
                        // 習得数の表示
                        Section(header: headerView()) {
                            ForEach(filteredEntries, id: \.entry) { entry in
                                if !isSelecting {
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
                                } else {
                                    HStack {
                                        Button(action: {
                                            toggleSelection(for: entry.entry)
                                        }) {
                                            Image(systemName: selectedEntries.contains(entry.entry) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedEntries.contains(entry.entry) ? .blue : .gray)
                                        }
                                        Text(entry.entry)
                                            .background(entry.status != 0 ? Color.green.opacity(0.3) : Color.clear)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if isSelecting {
                                            toggleSelection(for: entry.entry)
                                        }
                                    }
                                }
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
                    Text("全\(String(filteredEntries.count))単語")
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
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    if isSelecting {
                        Button(action: {
                            updateSelectedEntries(status: 0)
                        }) {
                            Text("未習得に")
                                .frame(maxWidth: .infinity) // ボタンの幅を均等にする
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isSelecting.toggle()
                        if !isSelecting {
                            selectedEntries.removeAll()
                        }
                    }) {
                        Text(isSelecting ? "キャンセル" : "選択")
                            .foregroundColor(isSelecting ? .red : .blue)
                            .frame(maxWidth: .infinity) // ボタンの幅を均等にする
                    }
                    
                    Spacer()
                    
                    if isSelecting {
                        Button(action: {
                            updateSelectedEntries(status: 1)
                        }) {
                            Text("習得に")
                                .frame(maxWidth: .infinity) // ボタンの幅を均等にする
                        }
                    }
                }
                .frame(maxWidth: .infinity) // HStack全体を広げる
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

    private func headerView() -> some View {
        // 習得数を計算
        let learnedCount = entries.filter { $0.status == 1 }.count
        let totalCount = entries.count

        return HStack {
            Text("習得数: \(learnedCount) / \(totalCount)")
                .font(.subheadline)
                .padding(.leading, 10)
            Spacer()
        }
    }

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

            for row in csv.rows {
                if let entry = row["entry"], let statusString = row["status"], let status = Int(statusString) {
                    loadedEntries.append((entry: entry, status: status))
                }
            }
            allEntries = loadedEntries

            if selectedSection == 0 {
                entries = allEntries
            } else {
                let startIndex = (selectedSection - 1) * 200
                let endIndex = selectedSection * 200
                entries = Array(allEntries[startIndex..<min(endIndex, allEntries.count)])
            }

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

    private func toggleSelection(for entry: String) {
        if selectedEntries.contains(entry) {
            selectedEntries.remove(entry)
        } else {
            selectedEntries.insert(entry)
        }
    }

    private func updateSelectedEntries(status: Int) {
        for entry in selectedEntries {
            if let index = allEntries.firstIndex(where: { $0.entry == entry }) {
                allEntries[index].status = status
            }
        }
        saveEntries()
        selectedEntries.removeAll()
        isSelecting = false
    }

    private func saveEntries() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let userCSVURL = documentDirectory.appendingPathComponent("\(material)_status.csv")
        
        var csvString = "entry,status\n"
        for entry in allEntries {
            csvString += "\(entry.entry),\(entry.status)\n"
        }
        
        do {
            try csvString.write(to: userCSVURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving CSV: \(error)")
        }
    }
}


import SwiftUI

struct DetailView: View {
    var material: String
    var entry: (entry: String, status: Int)
    var entries: [(entry: String, status: Int)]
    @Binding var lastViewedEntry: String?
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack {
            Spacer()
            AdMobView()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height * 1/9
                )
            GeometryReader { geometry in
                // 現在の currentIndex に対応する DetailCardView を表示
                DetailCardView(entry: entries[currentIndex], material: material)
                    .id(currentIndex)  // ビューの更新を強制
            }
            .onAppear {
                // 初回表示時のインデックス設定
                currentIndex = entries.firstIndex(where: { $0.entry == entry.entry }) ?? 0
                lastViewedEntry = entry.entry
            }
            
            HStack {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                        .opacity(currentIndex > 0 ? 1 : 0.5) // 最初のページではボタンを半透明にする
                }
                .disabled(currentIndex == 0) // 最初のページではボタンを無効化
                
                Spacer()
                
                Button(action: nextPage) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                        .opacity(currentIndex < entries.count - 1 ? 1 : 0.5) // 最後のページではボタンを半透明にする
                }
                .disabled(currentIndex == entries.count - 1) // 最後のページではボタンを無効化
            }
            Spacer()
        }
    }

    // 前のページに移動する
    private func previousPage() {
        if currentIndex > 0 {
            currentIndex -= 1
            lastViewedEntry = entries[currentIndex].entry
        }
    }

    // 次のページに移動する
    private func nextPage() {
        if currentIndex < entries.count - 1 {
            currentIndex += 1
            lastViewedEntry = entries[currentIndex].entry
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
    @State private var isFileEmpty = true // Track if the file is empty

    enum SortOrder {
        case alphabetical
    }

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if isFileEmpty {
                Text("追加された単語はありません")
                    .font(.headline)
                    .padding()
            } else {
                SearchBar(text: $searchQuery)
                    .padding()

                ScrollViewReader { proxy in
                    List {
                        ForEach(filteredEntries, id: \.entry) { entry in
                            HStack {
                                if isSelecting {
                                    Button(action: {
                                        toggleSelection(for: entry)
                                    }) {
                                        Image(systemName: selectedEntries.contains(entry.entry) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedEntries.contains(entry.entry) ? .blue : .gray)
                                    }
                                }
                                
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
        
        // ファイルが存在しない場合、空のCSVファイルを作成し、メッセージを表示
        if !FileManager.default.fileExists(atPath: starCSVURL.path) {
            let header = "entry,ipa,meaning,example_sentence,translated_sentence\n"
            do {
                try header.write(to: starCSVURL, atomically: true, encoding: .utf8)
                isFileEmpty = true
            } catch {
                errorMessage = "CSVファイルの作成エラー: \(error.localizedDescription)"
                return
            }
        } else {
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
                isFileEmpty = entries.isEmpty
                sortEntries()
            } catch {
                errorMessage = "CSVの読み込みエラー: \(error.localizedDescription)"
            }
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
        isFileEmpty = entries.isEmpty
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
        isFileEmpty = entries.isEmpty
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

    var body: some View {
        VStack {
            Spacer()
            AdMobView()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height * 1/9
                )
            if !entries.isEmpty {
                GeometryReader { geometry in
                    // 現在の currentIndex に対応する StarredDetailCardView を表示
                    StarredDetailCardView(entry: entries[currentIndex], removeAction: {
                        removeStarredEntry(entries[currentIndex])
                        removeEntry(at: currentIndex)
                    })
                    .id(currentIndex)  // ビューの更新を強制
                }
            } else {
                // エントリーがない場合のビュー
                Text("エントリーがありません")
                    .font(.headline)
                    .padding()
            }

            HStack {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                        .opacity(currentIndex > 0 ? 1 : 0.5) // 最初のページではボタンを半透明にする
                }
                .disabled(currentIndex == 0 || entries.isEmpty) // エントリーがない場合もボタンを無効化

                Spacer()

                Button(action: nextPage) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                        .opacity(currentIndex < entries.count - 1 ? 1 : 0.5) // 最後のページではボタンを半透明にする
                }
                .disabled(currentIndex >= entries.count - 1 || entries.isEmpty) // エントリーがない場合もボタンを無効化
            }

            Spacer()
        }
        .onAppear {
            // 初回表示時のインデックス設定
            currentIndex = entries.firstIndex(where: { $0.entry == entry.entry }) ?? 0
            lastViewedEntry = entry.entry
        }
    }

    // 前のページに移動する
    private func previousPage() {
        if currentIndex > 0 {
            currentIndex -= 1
            lastViewedEntry = entries[currentIndex].entry
        }
    }

    // 次のページに移動する
    private func nextPage() {
        if currentIndex < entries.count - 1 {
            currentIndex += 1
            lastViewedEntry = entries[currentIndex].entry
        }
    }

    private func removeEntry(at index: Int) {
        entries.remove(at: index)
        if entries.isEmpty {
            // エントリーが空になった場合、currentIndexを0にリセット
            currentIndex = 0
            lastViewedEntry = nil
        } else {
            if currentIndex >= entries.count {
                currentIndex = entries.count - 1
            }
            lastViewedEntry = entries[currentIndex].entry
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
}



struct DetailCardView: View {
    var entry: (entry: String, status: Int)
    var material: String
    @State private var entryDetails: (entry: String, ipa: String, meaning: String, example: String, translated: String) = ("", "", "", "", "")
    @StateObject private var speechRecognizer = SpeechRecognizer()  // 修正済みの SpeechRecognizer のインスタンス
    
    @State private var starredEntries: [(entry: String, ipa: String, meaning: String, example: String, translated: String)] = []
    @State private var currentStatus: Int = 0  // 現在のstatusを保持

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
            }
            .padding()
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height * 20/50
            )
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Spacer()

            Button(action: {
                speechRecognizer.speak(text: entryDetails.entry)  // 修正: speakText(_) を speechRecognizer.speak(text:) に置き換え
            }) {
                Text("発音再生")
            }
            .padding()
            
            if starredEntries.contains(where: { $0.0 == entryDetails.entry }) {
                Button(action: {
                    removeStarredEntry(entryDetails)
                    loadStarredEntries()
                }) {
                    Text("追加済み")
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                Button(action: {
                    saveStarredEntry(entryDetails)
                    loadStarredEntries()
                }) {
                    Text("後で復習")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            
            Button(action: {
                toggleStatus()
            }) {
                Text(currentStatus == 1 ? "未習得に" : "習得に")
                    .foregroundColor(currentStatus == 1 ? .red : .green)
            }
            .padding()
            
        }
        .onAppear {
            loadEntryDetails()
            loadStatus()
            loadStarredEntries()
            speechRecognizer.speak(text: entry.entry)  // 修正: onAppear内でも speechRecognizer.speak(text:) を使用
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

    func loadStatus() {
        // ステータスをstatus.csvから読み込む
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let statusCSVURL = documentDirectory.appendingPathComponent("\(material)_status.csv")

        do {
            let csv = try CSV<Named>(url: statusCSVURL)
            if let row = csv.rows.first(where: { $0["entry"] == entry.entry }),
               let statusString = row["status"],
               let status = Int(statusString) {
                currentStatus = status
            }
        } catch {
            print("Failed to load status: \(error.localizedDescription)")
        }
    }

    func toggleStatus() {
        currentStatus = currentStatus == 1 ? 0 : 1
        saveStatus()
    }

    func saveStatus() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let statusCSVURL = documentDirectory.appendingPathComponent("\(material)_status.csv")

        do {
            let csv = try CSV<Named>(url: statusCSVURL)
            var updatedRows = csv.rows

            if let rowIndex = updatedRows.firstIndex(where: { $0["entry"] == entry.entry }) {
                updatedRows[rowIndex]["status"] = "\(currentStatus)"
            }

            var updatedCSVString = "entry,status\n"
            for row in updatedRows {
                let entry = row["entry"] ?? ""
                let status = row["status"] ?? "0"
                updatedCSVString += "\(entry),\(status)\n"
            }

            try updatedCSVString.write(to: statusCSVURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving status: \(error.localizedDescription)")
        }
    }
    
    private func saveStarredEntry(_ entry: (String, String, String, String, String)) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let starCSVURL = documentDirectory.appendingPathComponent("star.csv")
        
        var starCSVString = ""
        
        if !FileManager.default.fileExists(atPath: starCSVURL.path) {
            starCSVString += "entry,ipa,meaning,example_sentence,translated_sentence\n"
        }
        
        // 各フィールドをエスケープしてCSVに追加
        let escapedEntry = escapeCSVField(entry.0)
        let escapedIPA = escapeCSVField(entry.1)
        let escapedMeaning = escapeCSVField(entry.2)
        let escapedExample = escapeCSVField(entry.3)
        let escapedTranslated = escapeCSVField(entry.4)
        
        starCSVString += "\(escapedEntry),\(escapedIPA),\(escapedMeaning),\(escapedExample),\(escapedTranslated)\n"
        
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
                let entry = escapeCSVField(row["entry"] ?? "")
                let ipa = escapeCSVField(row["ipa"] ?? "")
                let meaning = escapeCSVField(row["meaning"] ?? "")
                let example = escapeCSVField(row["example_sentence"] ?? "")
                let translated = escapeCSVField(row["translated_sentence"] ?? "")
                updatedCSVString += "\(entry),\(ipa),\(meaning),\(example),\(translated)\n"
            }

            try updatedCSVString.write(to: starCSVURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error removing starred entry: \(error)")
        }
    }

    private func escapeCSVField(_ field: String) -> String {
        var escapedField = field
        // ダブルクォートをエスケープ
        if escapedField.contains("\"") {
            escapedField = escapedField.replacingOccurrences(of: "\"", with: "\"\"")
        }
        // カンマや改行が含まれている場合、フィールドをダブルクォートで囲む
        if escapedField.contains(",") || escapedField.contains("\n") || escapedField.contains("\"") {
            escapedField = "\"\(escapedField)\""
        }
        return escapedField
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
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height * 20/50
            )
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Spacer()
            Button(action: {
                speechRecognizer.speak(text: entry.entry)
            }) {
                Text("発音再生")
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
            speechRecognizer.speak(text: entry.entry)
        }
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

