import SwiftUI

struct HomeMission: View {
    @State private var basic = false
    @State private var toeic = false
    @State private var business = false
    @State private var academic = false
    @StateObject private var missionState = MissionState()
    
    @State private var isReset: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationStack {
                    Button(action: {
                        basic = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("基礎英単語")
                                .font(.headline)
                            Spacer()  // ここにSpacerを追加
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)  // 横幅を最大に設定
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $basic) {
                        Pre_Mission(fromHome: true, material: "基礎英単語", reset: $isReset)// trueにすることで目覚ましと区別
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    Button(action: {
                        toeic = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("TOEIC英単語")
                                .font(.headline)
                            Spacer()  // ここにSpacerを追加
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)  // 横幅を最大に設定
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $toeic) {
                        Pre_Mission(fromHome: true, material: "TOEIC英単語", reset: $isReset)// trueにすることで目覚ましと区別
                            .navigationBarBackButtonHidden(true)
                    }
                
                    Button(action: {
                        business = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("ビジネス英単語")
                                .font(.headline)
                            Spacer()  // ここにSpacerを追加
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)  // 横幅を最大に設定
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $business) {
                        Pre_Mission(fromHome: true, material: "ビジネス英単語", reset: $isReset)// trueにすることで目覚ましと区別
                            .navigationBarBackButtonHidden(true)
                    }
                
                    Button(action: {
                        academic = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("学術英単語")
                                .font(.headline)
                            Spacer()  // ここにSpacerを追加
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)  // 横幅を最大に設定
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $academic) {
                        Pre_Mission(fromHome: true, material: "学術英単語", reset: $isReset)// trueにすることで目覚ましと区別
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    //デバイスに残っている通知チェック
                    Button(action: {
                        listAllPendingNotifications()
                    }) {
                        Text("Show Pending Notifications")
                    }
                    .padding()
                    
                    Button(action: {
                        removeAllPendingNotifications()
                    }) {
                        Text("Remove All Pending Notifications")
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("ミッション")
            .onAppear {
                isReset = true
                basic = false
                toeic = false
                business = false
                academic = false
            }
        }
    }
    
    func listAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("Identifier: \(request.identifier)")
                print("Content: \(request.content)")
                print("Trigger: \(String(describing: request.trigger))")
                print("-----")
            }
        }
    }

    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications have been removed.")
    }
}

#Preview {
    HomeMission()
}

