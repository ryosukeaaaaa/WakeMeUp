import SwiftUI

struct AlarmLandingView: View {
    @ObservedObject var alarmStore: AlarmStore
    // let alarmId: String
    let groupId: String
    @Binding var isPresented: Bool
    @State private var navigateToPreMission = false
    @State private var isReset: Bool = true

    var body: some View {
        NavigationStack {
            VStack {
                Text("アラーム")
                    .font(.largeTitle)
                    .padding()

                Text("起きる時間です！")
                    .font(.title2)
                    .padding()
                
                Text("GroupId: \(groupId)")
                    .font(.caption)
                    .padding()

                Button(action: {
                    navigateToPreMission = true
                    alarmStore.stopAlarm(alarmStore.groupId)  // アラームを止める
                    alarmStore.showingAlarmLanding = false
                }) {
                    Text("ミッション開始")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToPreMission) {
                Pre_Mission(reset: $isReset)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            print("AlarmLandingView appeared with groupId: \(groupId)")
        }
    }
}

