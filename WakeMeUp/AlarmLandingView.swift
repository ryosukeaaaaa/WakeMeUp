import SwiftUI

struct AlarmLandingView: View {
    @Binding var isAlarmActive: Bool
    @State private var navigateToPreMission = false

    var body: some View {
        VStack {
            Text("アラーム")
                .font(.largeTitle)
                .padding()

            Text("起きる時間です！")
                .font(.title2)
                .padding()

            Button(action: {
                stopAlarm()
                navigateToPreMission = true
            }) {
                Text("ミッション開始")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToPreMission) {
            Pre_Mission()
        }
    }

    private func stopAlarm() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        isAlarmActive = false
    }
}
