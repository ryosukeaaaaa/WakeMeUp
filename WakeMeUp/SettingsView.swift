import SwiftUI

struct SettingsView: View {
    @StateObject var missionState = MissionState()
    
    var body: some View {
        Form {
            Section(header: Text("設定")) {
                // ClearCountの設定
                Stepper(value: $missionState.ClearCount, in: 1...100) {
                    Text("出題回数: \(missionState.ClearCount)")
                }
                
                // materialの設定
                Picker("教材", selection: $missionState.material) {
                    Text("基礎英単語").tag("基礎英単語")
                    Text("TOEIC英単語").tag("TOEIC英単語")
                    Text("ビジネス英単語").tag("ビジネス英単語")
                    Text("学術英単語").tag("学術英単語")
                }
            }
        }
        .navigationTitle("設定")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
