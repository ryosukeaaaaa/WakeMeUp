import SwiftUI

struct HowToUse: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AlarmGuideView()) {
                    Text("アラームについて")
                }
                NavigationLink(destination: MissionGuideView()) {
                    Text("ミッションについて")
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
            .navigationTitle("操作説明")
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
                Text("アラームについて")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("右上の+ボタンからアラームを追加できます。アラームを同時にオンにできる個数はn個までなのでご注意ください。好きなサウンドを選んで音量を大中小から設定してください。")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("アラームについて")
    }
}

struct LearningStatusGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("学習状況について")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("学習状況が確認できます。")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("学習状況について")
    }
}

struct MissionGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("ミッションについて")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("アラームで起きた時以外でも発音テストをすることができます。練習を重ねて発音を上手くなろう。")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("ミッションについて")
    }
}


struct GachaGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("ガチャについて")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("毎朝ミッションをクリアするとチケットをもらえます。コインと交換してガチャを回そう。目指せコンプリート。")
                    .font(.body)
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
                Text("設定について")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("朝のミッションで出てくる単語の個数や単語帳を選べます。")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("設定について")
    }
}


