import SwiftUI

struct AlarmLandingView: View {
    @ObservedObject var alarmStore: AlarmStore
    let alarmId: String
    let groupId: String
    @Binding var isPresented: Bool
    @State private var navigateToPreMission = false

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
        .onAppear {
            print("AlarmLandingView appeared with groupId: \(groupId)")
        }
    }

    private func stopAlarm() {
        alarmStore.deleteAlarmsByGroupId(groupId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: (0...10).map { "AlarmNotification\(groupId)_\($0)" })
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: (0...10).map { "AlarmNotification\(groupId)_\($0)" })
        
        navigateToPreMission = true
    }
}
