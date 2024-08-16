import SwiftUI

struct AlarmLandingView: View {
    @ObservedObject var alarmStore: AlarmStore
    // let alarmId: String
    let groupId: [String]
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

                Button(action: {
                    navigateToPreMission = true
                    alarmStore.stopAlarm_All(alarmStore.groupIds)  // アラームを止める
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //画面が引き戻されるエラーが起こった。
                        alarmStore.showingAlarmLanding = false
                    }
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
                Pre_Mission(reset: $isReset, alarmStore: alarmStore)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            print("AlarmLandingView appeared with groupId: \(groupId)")
        }
    }
}

