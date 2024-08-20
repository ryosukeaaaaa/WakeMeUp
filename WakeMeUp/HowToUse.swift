import SwiftUI

struct HowToUse: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {  // Added spacing between the sections
                Section(header: Text("注意").font(.title2).foregroundColor(.red).fontWeight(.bold)) {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("アラームは、")
                                .fontWeight(.bold)
                            + Text("「消音モード」")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                            + Text("ではサウンドが鳴りません。")
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("また、")
                                .fontWeight(.bold)
                            + Text("「おやすみモード」").foregroundColor(.red)
                                .fontWeight(.bold)
                            + Text("では設定が必要です。\n以下の「おやすみモードの設定」から設定してください。")
                                .fontWeight(.bold)
                        }
                        Text("お手数おかけしますが、よろしくお願いします。")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                
                List {
                    Section(header: Text("基本機能").font(.headline)) {
                        NavigationLink(destination: AlarmGuideView()) {
                            Text("アラームについて")
                        }
                        NavigationLink(destination: MissionGuideView()) {
                            Text("英語演習について")
                        }
                        NavigationLink(destination: LearningStatusGuideView()) {
                            Text("学習状況について")
                        }
                        NavigationLink(destination: GachaGuideView()) {
                            Text("ガチャについて")
                        }
                        NavigationLink(destination: SettingsGuideView()) {
                            Text("設定について")
                        }
                    }
                    
                    // 新しいセクション
                    Section(header: Text("注意事項").font(.headline)) {
                        NavigationLink(destination: SleepModeGuideView()) {
                            Text("おやすみモードの設定")
                        }
                        NavigationLink(destination: SilentModeGuideView()) {
                            Text("消音モードとは")
                        }
                    }
                }
                .listStyle(GroupedListStyle())  // Using grouped style for a cleaner look
                
                
            }
            .navigationBarTitleDisplayMode(.inline)  // Inline title for a more compact appearance
        }
    }
}
struct OperationGuideView_Previews: PreviewProvider {
    static var previews: some View {
        HowToUse()
    }
}

struct AlarmGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("Alarm1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Text("※1度にオンにできるアラームは4つまでです。1つ当たり2分弱サウンドが流れます。（通知の都合上制限があります。ご理解いただけますと幸いです。）")
                    .font(.body)
                    .foregroundColor(.red)
                    .padding()
                Image("Alarm2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("Alarm3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Image("Alarm4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("アラームについて")
    }
}

struct MissionGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("Mission1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Image("Mission2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("Mission3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("英語演習について")
    }
}

struct LearningStatusGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("Status1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Image("Status2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("Status3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("学習状況について")
    }
}


struct GachaGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("GachaE1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Image("GachaE2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("GachaE3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("ガチャについて")
    }
}

struct SettingsGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("Setting")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("設定について")
    }
}

struct SleepModeGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("silent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Text("※アラームのサウンドを鳴らすためには、消音モードをオフにする必要があります。写真の丸部分のボタンを上に上げることで消音モードをオフにすることができます。")
                    .font(.body)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
            .padding()
        }
        .navigationTitle("アラームについて")
    }
}

struct SilentModeGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image("silent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Text("※アラームのサウンドを鳴らすためには、消音モードをオフにする必要があります。写真の丸部分のボタンを上に上げることで消音モードをオフにすることができます。")
                    .font(.body)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
            .padding()
        }
        .navigationTitle("アラームについて")
    }
}
