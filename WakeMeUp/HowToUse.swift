import SwiftUI

struct HowToUse: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {  // Added spacing between the sections
                Section(header: Text("注意").font(.title2).foregroundColor(.red).fontWeight(.bold)) {
                    VStack(alignment: .leading, spacing: 5) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("「通知」")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                            + Text("は必ず許可してください。")
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("・アラームは、")
                                .fontWeight(.bold)
                            + Text("「消音モード」")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                            + Text("では鳴りません。")
                                .fontWeight(.bold)
                            + Text("必ず消音モードをオフにしてください。")
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("・")
                                .fontWeight(.bold)
                            + Text("「おやすみモード」").foregroundColor(.red)
                                .fontWeight(.bold)
                            + Text("では設定が必要です。\n以下の「おやすみモードの設定」から設定してください。")
                                .fontWeight(.bold)
                        }
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
                Text("※サウンドは実際の音量で流れます。もし小さい場合は、「設定」→「サウンドと触覚」→「着信音と通知音」から大きくしてください。")
                    .font(.body)
                    .foregroundColor(.red)
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
            Text("※おやすみモードでサウンドを流すには設定が必要です。以下の手順を行うことを強く推奨します。\n")
                .font(.body)
                .foregroundColor(.red)
                .fontWeight(.bold)
            Image("sleep1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)  // Max width to fill parent width
                .padding()
            Image("sleep2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)  // Max width to fill parent width
                .padding()
            Text("から本アプリを追加してください。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            Text("よろしくお願いします。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
        }
        .navigationTitle("おやすみモードの設定")
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
        .navigationTitle("消音モードとは")
    }
}
