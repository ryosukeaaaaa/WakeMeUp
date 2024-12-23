import SwiftUI
import UserNotifications

struct MissionClear: View {
    @ObservedObject var missionState: MissionState
    @ObservedObject var alarmStore: AlarmStore
    
    @State private var Home = false

    var body: some View {
        NavigationStack{
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
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    } else {
                        Text("なし")
                            .font(.headline)
                            .background(Color(.secondarySystemBackground))
                    }
                }
                .padding()
                
                Button(action: {
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
            }
        }
    }
}

