import SwiftUI
import UserNotifications

struct MissionClear: View {
    @ObservedObject var missionState: MissionState
    @State private var HomeView = false
    @State private var navigationPath = NavigationPath()
    
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var Home = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
//                Spacer()
//                Text("Mission Complete!")
//                    .font(.title)
//                    .italic()
//                    .fontWeight(.semibold)
//                    .foregroundColor(.blue)
                Spacer()
                Text("今回の単語")
                    .font(.title)
                    .fontWeight(.semibold)
                    .italic()
                    .padding(.top)
                ScrollView {
                    ForEach(missionState.PastWords, id: \.self) { word in
                        HStack {
                            Text(" \(word["entry"] ?? "N/A")")
                            Spacer()
                            Text(" \(word["meaning"] ?? "N/A")")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                Button(action: {
                    // Clear the navigation stack and navigate to HomeView
                    navigationPath.removeLast(navigationPath.count)
                    // navigationPath.append("HomeView")
                    Home = true
                }) {
                    HStack {
                        Image(systemName: "house")
                        Text("ホームへ")
                            .font(.headline)
                    }
                    .padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationDestination(isPresented: $Home) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        navigationPath.removeLast(navigationPath.count)
                    }
            }
            .onAppear{
                alarmStore.showingAlarmLanding = false
            }
        }
    }
}
