import SwiftUI
import SwiftCSV

struct StatusView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationLink(destination: WordView(material: "基礎英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("基礎英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "TOEIC英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("TOEIC英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "ビジネス英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("ビジネス英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: WordView(material: "学術英単語")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("学術英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("学習状況")
        }
    }
}


struct WordView: View {
    let material: String
    @State private var entries: [(id: UUID, entry: String, status: Int)] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(entries, id: \.id) { entry in
                        HStack {
                            Text(entry.entry)
                            Spacer()
                            Text("\(entry.status)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle(material)
            .onAppear {
                createUserCSVIfNeeded2(material: material)
                loadEntries()
            }
        }
    }
    func createUserCSVIfNeeded2(material: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")
        
        if !FileManager.default.fileExists(atPath: userCSVURL.path) {
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
            var loadedEntries: [(id: UUID, entry: String, status: Int)] = []

            for row in csv.rows {
                if let entry = row["entry"], let statusString = row["status"], let status = Int(statusString) {
                    loadedEntries.append((id: UUID(), entry: entry, status: status))
                }
            }

            // statusの高い順に並べ替える
            entries = loadedEntries.sorted(by: { $0.status > $1.status })
        } catch {
            errorMessage = "CSVの読み込みエラー: \(error.localizedDescription)"
        }
    }
}

#Preview {
    WordView(material: "TOEIC英単語")
}

