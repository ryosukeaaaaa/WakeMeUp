import SwiftUI

struct SettingsView: View {
    @StateObject var missionState = MissionState()
    @State private var selectedMaterial = "基礎英単語"
    @State private var selectedSection = 1
    
    // 各教材に対応するセクションのデータ
    let sections = [
        "基礎英単語": [1, 2, 3],
        "TOEIC英単語": [1, 2, 3],
        "ビジネス英単語": [1, 2, 3],
        "学術英単語": [1, 2, 3]
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("出題設定")) {
                    // ClearCountの設定
                    Stepper(value: $missionState.ClearCount, in: 1...100) {
                        Text("出題回数: \(missionState.ClearCount)")
                    }
                    
                    // materialの設定
                    Picker("出題教材", selection: $selectedMaterial) {
                        ForEach(sections.keys.sorted(), id: \.self) { material in
                            Text(material).tag(material)
                        }
                    }
                    .onChange(of: selectedMaterial) {
                        // Reset the selected section when the material changes
                        selectedSection = sections[selectedMaterial]?.first ?? 1
                        missionState.section = selectedSection
                        missionState.material = selectedMaterial
                    }
                    
                    // 選択された教材に対応するセクションの設定
                    Picker("セクション", selection: $selectedSection) {
                        ForEach(sections[selectedMaterial] ?? [], id: \.self) { section in
                            Text("セクション \(section)").tag(section)
                        }
                    }
                    .onChange(of: selectedSection) {
                        missionState.section = selectedSection
                    }
                    Text("出題形式")
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
            }
            .navigationTitle("設定") // ここで画面タイトルを設定
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

