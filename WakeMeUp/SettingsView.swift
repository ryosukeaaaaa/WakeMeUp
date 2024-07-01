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
                Picker("素材", selection: $missionState.material) {
                    Text("TOEIC").tag("TOEIC")
                    Text("TOEFL").tag("TOEFL")
                    Text("IELTS").tag("IELTS")
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
