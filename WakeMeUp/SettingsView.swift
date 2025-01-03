import SwiftUI
import SwiftCSV

struct SettingsView: View {
    @StateObject var missionState = MissionState()
    @State private var selectedMaterial = "基礎英単語"
    @State private var selectedSection = 1
    @State private var showResetSheet = false  // Sheetの表示状態を管理するための状態変数
    
    @State private var deleteAlert = false
    
    @ObservedObject var alarmStore: AlarmStore
    
    // 各教材に対応するセクションのデータ
    let sections = [
        "基礎英単語": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
        "TOEIC英単語": [0, 1, 2, 3, 4, 5, 6, 7],
        "ビジネス英単語": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "学術英単語": [0, 1, 2, 3, 4, 5]
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("アラーム出題設定")) {
                    // ClearCountの設定
                    Stepper(value: $missionState.ClearCount, in: 1...100) {
                        Text("出題回数: \(missionState.ClearCount)")
                    }
                    
                    // materialの設定
                    Picker("アラーム出題教材", selection: $missionState.material) {
                        ForEach(Array(sections.keys), id: \.self) { material in
                            Text(material).tag(material)
                        }
                    }
                    
                    // 選択された教材に対応するセクションの設定
                    Picker("教材のセクション", selection: $missionState.section) {
                        ForEach(sections[missionState.material] ?? [], id: \.self) { section in
                            if section == 0 {
                                Text("全ての単語").tag(section)
                            } else {
                                Text("セクション \(section)").tag(section)
                            }
                        }
                    }
 
                    Picker("出題単語", selection: $missionState.Question) {
                        Text("未習得のみ").tag("未習得のみ")
                        Text("習得・未習得全て出題").tag("全て")
                    }
                }
                
                Section(header: Text("正解演出設定")) {
                    Picker("正解演出", selection: $missionState.correctcircle) {
                        Text("あり").tag("あり")
                        Text("なし").tag("なし")
                    }
                    
                    Stepper(value: $missionState.correctvolume, in: 0...1, step: 0.1) {
                        Text("正解音量: \(Int(round(missionState.correctvolume * 10) * 10))%")
                    }
                }
                
                Section(header: Text("本アプリの使い方")) {
                    NavigationLink {
                        HowToUse()
                    } label: {
                        Text("アプリの使用方法")
                    }
                    NavigationLink(destination: Contact()) {
                        Text("お問合せ・ご意見")
                    }
                    Link("よくある質問", destination: URL(string: "https://redboar1021.github.io/question/")!)
                }
                                
                Section(header: Text("その他")) {
                    Link("利用規約", destination: URL(string: "https://redboar1021.github.io/terms-of-service/")!)
                    Link("プライバシーポリシー", destination: URL(string: "https://redboar1021.github.io/privacy-policy/")!)
                    Link("著作権とライセンス", destination: URL(string: "https://redboar1021.github.io/Copyright/")!)
                }
                
                Section(header: Text("データリセット")) {
                    Button(action: {
                        showResetSheet = true  // Sheetを表示するために状態を更新
                    }) {
                        Text("習得状況のリセット")
                            .foregroundColor(.red)
                    }
                    .sheet(isPresented: $showResetSheet) {
                        ResetStatusSheetView()
                            .presentationDetents([.fraction(2/5)]) // 1/4の高さで表示
                    }
                    Button(action: {
                        deleteAlert = true
                    }) {
                        Text("現在のアラームを全て消去")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $deleteAlert) {
                        Alert(
                            title: Text("確認"),
                            message: Text("本当に現在のアラームを全て消去しますか？"),
                            primaryButton: .default(Text("はい"), action: {
                                removeAllPendingNotifications()
                                alarmStore.alarms.removeAll()
                                alarmStore.saveAlarms()
                            }),
                            secondaryButton: .cancel(Text("いいえ"))
                        )
                    }
                }

                
                // 一番下にメッセージを追加
                Section {
                    Text("Apple Storeにて高評価・レビューのご協力よろしくお願いします！")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                    Link("レビューを書く", destination: URL(string: "https://apps.apple.com/jp/app/%E6%9C%9D%E5%8D%98-%E8%8B%B1%E5%8D%98%E8%AA%9E%E3%82%A2%E3%83%A9%E3%83%BC%E3%83%A0/id6651821144?action=write-review")!)
                }
            }
            .navigationTitle("設定") // ここで画面タイトルを設定
        }
    }
//    func listAllPendingNotifications() {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            for request in requests {
//                print("Identifier: \(request.identifier)")
//                print("Content: \(request.content)")
//                print("Trigger: \(String(describing: request.trigger))")
//                print("-----")
//            }
//        }
//    }

    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications have been removed.")
    }
}

struct ResetStatusSheetView: View {
    @State private var showAlert = false
    @State private var selectedMaterial: String?
    
    let materials = ["基礎英単語", "TOEIC英単語", "ビジネス英単語", "学術英単語"]
    
    var body: some View {
        VStack {
            Text("習得状況のリセット")
                .font(.headline)
                .padding()
            
            List(materials, id: \.self) { material in
                Button(action: {
                    selectedMaterial = material
                    showAlert = true  // アラート表示のトリガーをセット
                }) {
                    Text(material)
                        .foregroundColor(.blue)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("本当に実行しますか？"),
                        message: Text("\(selectedMaterial ?? "")の習得状況がリセットされます。"),
                        primaryButton: .destructive(Text("リセット")) {
                            if let material = selectedMaterial {
                                resetStatusesToZero(material: material)
                                dismiss()
                            }
                        },
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
            }
            .listStyle(.plain)
            
            Button("キャンセル", action: {
                dismiss()
            })
            .padding()
        }
    }
    
    @Environment(\.dismiss) var dismiss  // シートを閉じるための環境変数
    
    private func resetStatusesToZero(material: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userCSVURL = documentDirectory.appendingPathComponent(material + "_status" + ".csv")
        
        guard let csvURL_status = Bundle.main.url(forResource: material, withExtension: "csv") else {
            print("Error: CSVファイルが見つかりません")
            return
        }
        
        do {
            // リソースからCSVファイルを読み込む
            let csv = try CSV<Named>(url: csvURL_status)
            var userCSVString = "entry,status\n"
            
            // リソースのCSVファイルを基に新しいCSV文字列を作成する
            for row in csv.rows {
                if let entry = row["entry"] {
                    userCSVString += "\(entry),0\n"
                }
            }
            
            // 新しいCSV文字列をユーザーのディレクトリに保存する
            try userCSVString.write(to: userCSVURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("Error resetting statuses to zero: \(error)")
        }
    }
}

struct Contact: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("お問い合わせ・ご意見等ございましたら、")
                .fontWeight(.bold)
            Text("メールアドレス")
                .fontWeight(.bold)
            Text("asatan_official@icloud.com")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = "asatan_official@icloud.com"
                    }) {
                        Text("メールアドレスをコピー")
                            .fontWeight(.bold)
                    }
                }
            Text("にてメッセージいただくか、")
                .fontWeight(.bold)
            Text("または本アプリのX公式アカウント(英単語アラーム)")
                .fontWeight(.bold)
            Text("@asatanX")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = "@asatanX"
                    }) {
                        Text("アカウント名をコピー")
                            .fontWeight(.bold)
                    }
                }
            Text("にてDMしていただけると幸いです。")
                .fontWeight(.bold)
            Text("よろしくお願いいたします。")
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .navigationTitle("お問い合わせ・ご意見")
    }
}
