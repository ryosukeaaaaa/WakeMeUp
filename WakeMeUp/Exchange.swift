import SwiftUI

struct Exchange: View {
    @ObservedObject var itemState: ItemState
    
    @State private var showAlert: Bool = false
    @State private var normalExchangeCount: Int = 0
    @State private var specialExchangeCount: Int = 0
    
    // 必要なチケット枚数を計算
    var totalRequiredTickets: Int {
        (normalExchangeCount * 5) + (specialExchangeCount * 10)
    }
    
    // ノーマルコインの交換可能な最大値を計算
    var maxNormalExchangeCount: Int {
        (itemState.Ticket - (specialExchangeCount * 10)) / 5
    }
    
    // スペシャルコインの交換可能な最大値を計算
    var maxSpecialExchangeCount: Int {
        (itemState.Ticket - (normalExchangeCount * 5)) / 10
    }
    
    // アラートメッセージの生成
    var alertMessage: String {
        var message = "本当に \(totalRequiredTickets) 枚のチケットを\n"
        if normalExchangeCount > 0 {
            message += "ノーマルコイン：\(normalExchangeCount) 枚\n"
        }
        if specialExchangeCount > 0 {
            message += "スペシャルコイン：\(specialExchangeCount) 枚\n"
        }
        message += "と交換しますか？"
        return message
    }
    
    var body: some View {
        VStack() {
            Spacer()
            HStack{
                VStack{
                    Text("所持チケット枚数:")
                    HStack{
                        Image("Ticket")
                            .resizable()
                            .frame(width: 40, height: 40)  // 画像のサイズを調整
                        Text("\(itemState.Ticket) 枚")
                            .font(.title)
                            .padding()
                    }
                }
                Spacer()
                VStack{
                    Text("必要チケット枚数:")
                    HStack{
                        Image("Ticket")
                            .resizable()
                            .frame(width: 40, height: 40)  // 画像のサイズを調整
                        Text("\(totalRequiredTickets) 枚")
                            .font(.title)
                            .padding()
                    }
                }
            }
            .padding()
            VStack(alignment: .leading) {
                Text("交換するコイン")
                    .font(.headline)
                VStack {
                    Stepper(value: $normalExchangeCount, in: 0...maxNormalExchangeCount) {
                        HStack{
                            Image("NormalCoin")
                                .resizable()
                                .frame(width: 40, height: 40)  // 画像のサイズを調整
                            Text("ノーマルコイン: \(normalExchangeCount) 枚")
                        }
                    }
                    
                    Stepper(value: $specialExchangeCount, in: 0...maxSpecialExchangeCount) {
                        HStack{
                            Image("SpecialCoin")
                                .resizable()
                                .frame(width: 40, height: 40)  // 画像のサイズを調整
                            Text("スペシャルコイン: \(specialExchangeCount) 枚")
                        }
                    }
                }
                .padding(.vertical)
                
            }
            Button(action: {
                if normalExchangeCount > 0 || specialExchangeCount > 0{
                    showAlert = true  // アラートを表示する
                }
            }) {
                Text("交換")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("はい"), action: {
                        itemState.NormalCoin += normalExchangeCount
                        itemState.SpecialCoin += specialExchangeCount
                        itemState.Ticket -= totalRequiredTickets
                        normalExchangeCount = 0 // 交換後にリセット
                        specialExchangeCount = 0 // 交換後にリセット
                    }),
                    secondaryButton: .cancel(Text("いいえ"))
                )
            }
            Spacer()
            
            AdMobView()
                .frame(width: 450, height: 300)
        }
        .navigationTitle("チケット交換")
        .padding()
    }
    
}
