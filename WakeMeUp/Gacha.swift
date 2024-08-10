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
                        Image(systemName: "lock.shield")
                        Text("ノーマルガチャ")
                            .font(.headline)
                        Spacer()
                        Text("所持コイン: \(itemState.NormalCoin)")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                NavigationLink(destination: GachaGIF2(itemState: itemState)) {
                    HStack {
                        Image(systemName: "lock.shield")
                        Text("スペシャルガチャ")
                            .font(.headline)
                        Spacer()
                        Text("所持コイン: \(itemState.SpecialCoin)")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    itemState.NormalCoin = 10
                    itemState.SpecialCoin = 10
                }) {
                    Text("コインテスト")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
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
                            Text("Rare(全14種)")
                            Spacer()
                            Text("28 %")
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("SuperRare(全9種)")
                            Spacer()
                            Text("9 %")
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
                        
                        HStack {
                            Text("Secret(全2種)")
                            Spacer()
                            Text("1 %")
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
                    .frame(width: 450, height: 200)
            }
            .padding()
        }
    }
}

