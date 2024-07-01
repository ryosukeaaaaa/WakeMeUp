import SwiftUI

class issionState: ObservableObject {
    @Published var missionCount: Int = 0
    @Published var ClearCount: Int = 10 // 例として
    @Published var clear_mission: Bool = false
    @Published var shouldLoadInitialEntry: Bool = false
}

struct ContentView2: View {
    @StateObject private var missionState = issionState()
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Mission Count: \(missionState.missionCount)")
                Button("Increment") {
                    missionState.missionCount += 1
                }
            }
            .onChange(of: missionState.missionCount) {
                if missionState.missionCount >= missionState.ClearCount {
                    missionState.missionCount = 0
                    missionState.clear_mission = false
                    missionState.shouldLoadInitialEntry = true
                    navigateToHome = true
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MissionClear()
                    .onAppear {
                        navigateToHome = false
                    }
            }
        }
    }
}

struct MissionClear2: View {
    var body: some View {
        Text("Mission Clear!")
    }
}

//@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
    }
}

