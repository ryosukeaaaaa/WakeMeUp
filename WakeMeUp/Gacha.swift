import SwiftUI
import SpriteKit

struct Gacha: View {
    @ObservedObject var itemState: ItemState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Spacer()
                
                NavigationLink(destination: GachaGIF(itemState: itemState)) {
                    HStack {
                        Image("NormalCoin")
                            .resizable()
                            .frame(width: 30, height: 30)  // 画像のサイズを調整
                        Text("ノーマルガチャ")
                            .font(.headline)
                        Spacer()
//                        Text("所持コイン: \(itemState.NormalCoin)")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                NavigationLink(destination: GachaGIF2(itemState: itemState)) {
                    HStack {
                        Image("SpecialCoin")
                            .resizable()
                            .frame(width: 30, height: 30)  // 画像のサイズを調整
                        Text("スペシャルガチャ")
                            .font(.headline)
                        Spacer()
//                        Text("所持コイン: \(itemState.SpecialCoin)")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
//                Button(action: {
//                    itemState.NormalCoin = 10
//                    itemState.SpecialCoin = 10
//                }) {
//                    Text("コインテスト")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
                
                VStack {
                    VStack {
                        HStack {
                            Text("レアリティ")
                                .font(.headline)
                            Spacer()
                            Text("排出確率")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        HStack {
                            Text("Normal(全15種)")
                            Spacer()
                            Text("60 %")
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Rare(全15種)")
                            Spacer()
                            Text("30 %")
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("SuperRare(全8種)")
                            Spacer()
                            Text("8 %")
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("UltraRare(全4種)")
                            Spacer()
                            Text("2 %")
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
                
                Spacer()
                
                AdMobView()
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height * 1/3
                    )
            }
            .padding()
        }
        .navigationTitle("ガチャ")
    }
}

