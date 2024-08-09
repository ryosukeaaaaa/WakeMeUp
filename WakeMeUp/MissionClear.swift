import SwiftUI
import UserNotifications

struct MissionClear: View {
    @ObservedObject var missionState: MissionState
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var Home = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Spacer()
                
                Text("今回の単語")
                    .font(.title)
                    .fontWeight(.semibold)
                    .italic()
                    .padding(.top)
                
                ScrollView {
                    if let latestWords = missionState.PastWords.last, !latestWords.isEmpty {
                        ForEach(latestWords, id: \.self) { word in
                            HStack {
                                Text(" \(word["entry"] ?? "N/A")")
                                Spacer()
                                Text(" \(word["meaning"] ?? "N/A")")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    } else {
                        Text("なし")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                Button(action: {
                    // Clear the navigation stack and navigate to HomeView
                    navigationPath.removeLast(navigationPath.count)
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
        }
    }
}

