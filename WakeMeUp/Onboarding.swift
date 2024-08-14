import SwiftUI

struct OnboardingView: View {
    @State private var selectedPage = 1
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        VStack {
            TabView(selection: $selectedPage) {
                FirstPageView()
                    .tag(1)

                SecondPageView()
                    .tag(2)

                ThirdPageView()
                    .tag(3)

                FourthPageView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedPage)

            Spacer()

            HStack {
                ForEach(1...4, id: \.self) { index in
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(selectedPage == index ? .blue : .gray)
                        .onTapGesture {
                            selectedPage = index
                        }
                }
            }
            .padding(.bottom, 20)

            Button(action: {
                if selectedPage < 4 {
                    selectedPage += 1
                } else {
                    hasSeenOnboarding = true  // 完了後にフラグを設定
                }
            }) {
                Text(selectedPage == 4 ? "完了" : "次へ")
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}



// 各ページのビューを定義
struct FirstPageView: View {
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("始める前に")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                Text("このアプリは、通知、音声認識、マイクの許可が")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                HStack() {
                    Text("必須")
                        .font(.title3)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    
                    Text("です。全て許可してください。")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                }
                Text("（設定からも変更できます。）")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
//                Spacer()
            }
            
            Image("1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

struct SecondPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("使い方")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.blue)
            }
            Text("本アプリは、")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)

            Text("「英単語を発音しないと止まらないアラーム」")
                .font(.title3)
                .foregroundColor(.blue)
                .fontWeight(.bold)

            Text("です。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)

            Text("アラームを止めるとき単語画面が現れます。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            HStack {
                Spacer() // 左側のスペーサー
                Image("3-1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer() // 右側のスペーサー
            }
            .padding(.bottom, 20)
            Text("赤いボタンを長押ししながら表示単語を発音！")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            Text("正しく認識されると次のステップへ！")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
        }
        .padding()
    }
}

struct ThirdPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
//            VStack(alignment: .leading, spacing: 5) {
//                Text("発音説明")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(.blue)
//                    .padding(.top, 20)
//                Rectangle()
//                    .frame(height: 2)
//                    .foregroundColor(.blue)
//            }
            Spacer()
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.blue)
            Text("正解後、その単語を習得できていれば右、まだなら左にスワイプ！以降の出題に反映されます!")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            HStack{
                Image("3-2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 20)
                Spacer()
                Image("3-3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 20)
            }
            HStack{
                Text("もちろん習得状況の確認もできます。")
                    .font(.body)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                Spacer()
                Image("3-4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 20)
            }
        }
        .padding()
    }
}

struct FourthPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("注意")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.blue)
            }
            Text("おやすみモードでサウンドを流すには設定が必要です。以下の手順を行うことを強く推奨します。\n")
                .font(.body)
                .foregroundColor(.red)
                .fontWeight(.bold)
            HStack{
                VStack{
                    Text("「設定」>")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Image("4-1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 20)
                }
                VStack{
                    Text("「集中モード」>")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Image("4-2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 20)
                }
            }
            HStack{
                VStack{
                    Text("「おやすみモード」>")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Image("4-3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 20)
                }
                VStack{
                    Text("「追加」")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Image("4-4")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 20)
                }
            }
            Text("より本アプリを追加してください。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
            Text("お手数おかけしますが、よろしくお願いします。")
                .font(.body)
                .foregroundColor(.primary)
                .fontWeight(.bold)
        }
        .padding()
    }
}

