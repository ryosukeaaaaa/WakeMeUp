import SwiftUI

struct HomeMission: View {
    @State private var basic = false
    @State private var toeic = false
    @State private var business = false
    @State private var academic = false
    @StateObject private var missionState = MissionState()
    
    @State private var isReset: Bool = true
    
    @State private var lastmission = false
    
    @State private var alarmStore = AlarmStore()
    
    @State private var selectedSection: Int = 0  // 新しい状態変数を追加
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                Button(action: {
                    basic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("基礎英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $basic) {
                    SectionSelectionView(material: "基礎英単語", sectionCount: 15, isPresented: $basic, selectedSection: $selectedSection, reset: $isReset)
                }
                
                Button(action: {
                    toeic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("TOEIC英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $toeic) {
                    SectionSelectionView(material: "TOEIC英単語", sectionCount: 7, isPresented: $toeic, selectedSection: $selectedSection, reset: $isReset)
                }
                
                Button(action: {
                    business = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("ビジネス英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $business) {
                    SectionSelectionView(material: "ビジネス英単語", sectionCount: 9, isPresented: $business, selectedSection: $selectedSection, reset: $isReset)
                }
                
                Button(action: {
                    academic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("学術英単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $academic) {
                    SectionSelectionView(material: "学術英単語", sectionCount: 5, isPresented: $academic, selectedSection: $selectedSection, reset: $isReset)
                }
                
                Button(action: {
                    lastmission = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("前回の単語")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $lastmission) {
                    LastMission(missionState: missionState)
                }
                
                VStack {
                    VStack {
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
                            Text("\(missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount)回")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                }
                
                Spacer()
                
                AdMobView()
                    .frame(width: 450, height: 90)
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

