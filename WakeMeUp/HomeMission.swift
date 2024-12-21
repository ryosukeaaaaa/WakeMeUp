import SwiftUI
import UserNotifications
import AVFoundation
import Speech

struct HomeMission: View {
    @State private var basic = false
    @State private var toeic = false
    @State private var business = false
    @State private var academic = false
    @EnvironmentObject var  missionState: MissionState
    
    @State private var isReset: Bool = true
    
    @State private var lastmission = false
    
    @State private var alarmStore = AlarmStore()
    
    @State private var selectedSection: Int = 0  // 新しい状態変数を追加
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationView {
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
                        SectionSelectionView(missionState: missionState, material: "基礎英単語", sectionCount: 15, isPresented: $basic, selectedSection: $selectedSection, reset: $isReset)
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
                        SectionSelectionView(missionState: missionState, material: "TOEIC英単語", sectionCount: 7, isPresented: $toeic, selectedSection: $selectedSection, reset: $isReset)
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
                        SectionSelectionView(missionState: missionState, material: "ビジネス英単語", sectionCount: 9, isPresented: $business, selectedSection: $selectedSection, reset: $isReset)
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
                        SectionSelectionView(missionState: missionState, material: "学術英単語", sectionCount: 5, isPresented: $academic, selectedSection: $selectedSection, reset: $isReset)
                    }
                    
                    Button(action: {
                        lastmission = true
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("過去の出題単語")
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
                        HStack {
                            Text("基礎英単語")
                                .font(.system(size: 14)) // 一回り小さく
                            Spacer()
                            Text("\(missionState.basicCount)回")
                                .font(.system(size: 14)) // 一回り小さく
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("TOEIC英単語")
                                .font(.system(size: 14)) // 一回り小さく
                            Spacer()
                            Text("\(missionState.toeicCount)回")
                                .font(.system(size: 14)) // 一回り小さく
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("ビジネス英単語")
                                .font(.system(size: 14)) // 一回り小さく
                            Spacer()
                            Text("\(missionState.businessCount)回")
                                .font(.system(size: 14)) // 一回り小さく
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("学術英単語")
                                .font(.system(size: 14)) // 一回り小さく
                            Spacer()
                            Text("\(missionState.academicCount)回")
                                .font(.system(size: 14)) // 一回り小さく
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal)
                        
                        Divider()
                        
                        HStack {
                            Text("総演習回数")
                                .font(.system(size: 14)) // 一回り小さく
                                .fontWeight(.bold) // ヘッドライン用に太字
                            Spacer()
                            Text("\(missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount)回")
                                .font(.system(size: 14)) // 一回り小さく
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 1/7) // 特定の高さを設定
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5) // 角丸を設定
                    .overlay(
                        RoundedRectangle(cornerRadius: 5) // 枠線を追加
                            .stroke(Color.gray, lineWidth: 1) // 枠線の色と幅を設定
                    )
                    
                    HStack{
                        if ((missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount) / 25) % 4 == 3{
                            Image("SpecialCoin")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("スペシャル")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        else{
                            Image("NormalCoin")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("ノーマル")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        Text("コインまであと\((missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount) % 25 == 0 ? 25 : (25 - (missionState.basicCount + missionState.toeicCount + missionState.businessCount + missionState.academicCount) % 25))回")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    AdMobView()
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height * 1/9
                        )
                }
            }
            .padding()
            .navigationTitle("英語演習")
            .onAppear {
                isReset = true
                basic = false
                toeic = false
                business = false
                academic = false
                checkPermissions()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func checkPermissions() {
        checkMicrophonePermission()
        checkSpeechRecognitionPermission()
    }
    
    private func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        alertTitle = "[重要]マイクの許可が必要"
                        alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                        showAlert = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                alertTitle = "[重要]マイクの許可が必要"
                alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                showAlert = true
            }
        @unknown default:
            DispatchQueue.main.async {
                alertTitle = "[重要]マイクの許可が必要"
                alertMessage = "音声認識を有効にするにはマイクの許可が必要です。設定からマイクを許可してください。"
                showAlert = true
            }
        }
    }

    private func checkSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    break
                case .denied, .restricted, .notDetermined:
                    alertTitle = "[重要]音声認識の許可が必要"
                    alertMessage = "発音判定に音声認識の許可が必要です。設定から音声認識を許可してください。"
                    showAlert = true
                @unknown default:
                    alertTitle = "[重要]音声認識の許可が必要"
                    alertMessage = "発音判定に音声認識の許可が必要です。設定から音声認識を許可してください。"
                    showAlert = true
                }
            }
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
            Text("過去の出題単語")
                .font(.title)
                .fontWeight(.semibold)
                .italic()
                .padding(.top)
            ScrollView {
                ForEach(Array(missionState.PastWords.reversed().enumerated()), id: \.offset) { index, words in
                    if !words.isEmpty {
                        VStack(alignment: .leading) {
                            Text("\(index + 1)回前")
                                .font(.headline)
                                .padding(.bottom, 5)
                            ForEach(words, id: \.self) { word in
                                HStack {
                                    Text(" \(word["entry"] ?? "N/A")")
                                    Spacer()
                                    Text(" \(word["meaning"] ?? "N/A")")
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 15)
                    }
                }
            }
            .padding()
        }
    }
}


