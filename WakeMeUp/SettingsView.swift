import SwiftUI

struct SettingsView: View {
    @StateObject var missionState = MissionState()
    @State private var selectedMaterial = "基礎英単語"
    @State private var selectedSection = ""
    
    // 各教材に対応するセクションのデータ
    let sections = [
        "基礎英単語": ["セクション1", "セクション2", "セクション3"],
        "TOEIC英単語": ["セクションA", "セクションB", "セクションC"],
        "ビジネス英単語": ["セクションX", "セクションY", "セクションZ"],
        "学術英単語": ["セクションα", "セクションβ", "セクションγ"]
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // ClearCountの設定
                    Stepper(value: $missionState.ClearCount, in: 1...100) {
                        Text("出題回数: \(missionState.ClearCount)")
                    }
                    
                    // materialの設定
                    Picker("出題教材", selection: $missionState.material) {
                        Text("基礎英単語").tag("基礎英単語")
                        Text("TOEIC英単語").tag("TOEIC英単語")
                        Text("ビジネス英単語").tag("ビジネス英単語")
                        Text("学術英単語").tag("学術英単語")
                    }
                    
                    // 選択された教材に対応するセクションの設定
                    Picker("セクション", selection: $selectedSection) {
                        ForEach(sections[selectedMaterial] ?? [], id: \.self) { section in
                            Text(section).tag(section)
                        }
                    }
                    
                    Picker("正解演出", selection: $missionState.correctcircle) {
                        Text("あり").tag("あり")
                        Text("なし").tag("なし")
                    }
                }
            }
            .navigationTitle("設定") // ここで画面タイトルを設定
        }
    }
}

#Preview {
    SettingsView()
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
