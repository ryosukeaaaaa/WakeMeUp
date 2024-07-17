import SwiftUI


struct Collection: View {
    @ObservedObject var itemState: ItemState

    var body: some View {
        VStack {
            Button(action: {
                itemState.UserItems.removeAll() // itemState.UserItemsを空にする
            }) {
                Text("コレクションをリセット")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            ScrollView {
                VStack {
                    ForEach(itemState.ItemSources, id: \.name) { item in
                        VStack {
                            if itemState.UserItems.contains(item.name) {
                                Image(item.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                Text(item.name)
                                Text("Rarity: \(item.rarity.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Color.clear
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.3)) // 未入手アイテムの背景色
                                Text("未入手")
                                    .foregroundColor(.red)
                                Text("Rarity: \(item.rarity.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity) // スクロールビューの横幅を最大にする
            }
        }
        .navigationTitle("My Collection")
    }
}
