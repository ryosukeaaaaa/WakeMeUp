import SwiftUI
import KeyboardObserving // KeyboardObservingライブラリをインポート

struct HomeMission: View {
    @State private var basic = false
    @State private var toeic = false
    @State private var business = false
    @State private var academic = false
    @StateObject private var missionState = MissionState()
    
    @State private var isReset: Bool = true
    
    @State private var lastmission = false
    
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
                    
                    //　前回の単語
                    Button(action: {
                        lastmission = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("前回の単語")
                                .font(.headline)
                            Spacer()  // ここにSpacerを追加
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)  // 横幅を最大に設定
                        .background(Color.cyan)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $lastmission) {
                        LastMission(missionState: missionState)
                    }
                    
                    VStack {
                        VStack {
    //                        HStack {
    //                            Text("カテゴリー")
    //                                .font(.headline)
    //                            Spacer()
    //                            Text("演習回数")
    //                                .font(.headline)
    //                        }
    //                        .padding(.horizontal)
    //
    //                        Divider()
                            HStack {
                                Text("基礎英単語")
                                Spacer()
                                Text("\(missionState.basicCount)回")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("TOEIC英単語")
                                Spacer()
                                Text("\(missionState.toeicCount)回")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("ビジネス英単語")
                                Spacer()
                                Text("\(missionState.businessCount)回")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("学術英単語")
                                Spacer()
                                Text("\(missionState.academicCount)回")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal)
                            
                            Divider()
                            
                            HStack {
                                Text("総演習回数")
                                    .font(.headline)
                                Spacer()
                                Text("\(missionState.basicCount+missionState.toeicCount+missionState.businessCount+missionState.academicCount)回")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
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

struct LastMission: View {
    @ObservedObject var missionState: MissionState
    
    @StateObject private var alarmStore = AlarmStore()
    
    @State private var Home = false

    var body: some View {
        VStack {
            Text("前回の単語")
                .font(.title)
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
        }
    }
}
