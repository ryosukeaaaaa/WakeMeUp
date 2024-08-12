import SwiftUI
import SwiftCSV

struct StatusSectionSelectView: View {
    let material: String
    let sectionCount: Int
    @Binding var isPresented: Bool
    @Binding var selectedSection: Int
    @State private var isNormalWordViewPresented: Bool = false
    @State private var learnedCounts: [(learned: Int, total: Int)] = []

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<sectionCount + 1, id: \.self) { section in
                        Button(action: {
                            selectedSection = section
                            isNormalWordViewPresented = true
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(section == 0 ? "全範囲" : "セクション \(section)")
                                    .font(.headline)
                                Spacer()
                                if section < learnedCounts.count {
                                    let count = learnedCounts[section]
                                    Text("\(count.learned) / \(count.total)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(section == 0 ? Color.orange : Color(red: 1.2, green: 0.8, blue: 0.1))  //条件付きで背景色を設定
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            Spacer()
            AdMobView()
                .frame(width: 450, height: 90)
        }
        .padding()
        .navigationTitle("全\(sectionCount)セクション")
        .navigationDestination(isPresented: $isNormalWordViewPresented) {
            NormalWordView(material: material, selectedSection: selectedSection)
        }
        .onAppear {
            calculateLearnedCounts()
        }
    }

    private func calculateLearnedCounts() {
        DispatchQueue.global(qos: .userInitiated).async {
            var counts: [(learned: Int, total: Int)] = []
            for section in 0..<sectionCount + 1 {
                let startIndex = section == 0 ? 0 : (section - 1) * 200
                let endIndex = section == 0 ? .max : section * 200

                // CSVファイルを読み込み、習得数とセクションの単語数をカウント
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let userCSVURL = documentDirectory.appendingPathComponent("\(material)_status.csv")
                    do {
                        let csv = try CSV<Named>(url: userCSVURL)
                        var learnedCount = 0
                        var totalCount = 0
                        var currentIndex = 0
                        for row in csv.rows {
                            if currentIndex >= startIndex && currentIndex < endIndex {
                                if let statusString = row["status"], let status = Int(statusString) {
                                    if status == 1 {
                                        learnedCount += 1
                                    }
                                }
                                totalCount += 1
                            }
                            currentIndex += 1
                        }
                        counts.append((learned: learnedCount, total: totalCount))
                    } catch {
                        print("CSV読み込みエラー: \(error.localizedDescription)")
                        counts.append((learned: 0, total: 0))
                    }
                } else {
                    counts.append((learned: 0, total: 0))
                }
            }
            DispatchQueue.main.async {
                learnedCounts = counts
            }
        }
    }
}

