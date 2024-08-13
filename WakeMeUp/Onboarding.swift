import SwiftUI

// Onboardingのメインビュー
struct OnboardingView: View {
    @State private var selectedPage = 1

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
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: selectedPage)

            Spacer()

            // ページインジケーターとナビゲーションボタン
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
        VStack(alignment: .leading, spacing: 20) {
            Text("始める前に")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Text("このアプリは、通知、音声認識、マイクの許可が")
                .font(.body)
                .foregroundColor(.primary)

            Text("必須")
                .font(.body)
                .foregroundColor(.red)
                .fontWeight(.bold)

            Text("です。全て許可してください。")
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

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
            Text("使い方")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Text("本アプリは、")
                .font(.body)
                .foregroundColor(.primary)

            Text("・朝スムーズに起きたい人\n・英単語に毎日触れたい人")
                .font(.body)
                .foregroundColor(.blue)
                .fontWeight(.medium)

            Text("に向けた\n「英単語を発音しないと止まらないアラーム」です。")
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image("2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

struct ThirdPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("発音説明")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Text("ボタンを押しながら表示された単語を発音！\nクリアすると次のステップへ！\nその単語を習得できれば右（習得）へ、まだなら左（未習得）へスワイプ！")
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image("3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

struct FourthPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("注意")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Text("おやすみモードではサウンドが流れません。\n「設定」→「おやすみモード」→「アプリ」→「追加」から本アプリを追加してください。")
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image("4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

