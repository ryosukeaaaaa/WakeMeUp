import SwiftUI


// 各アイテムのビューを定義
struct ItemView: View {
    let item: Item
    let isOwned: Bool

    var body: some View {
        VStack {
            if isOwned {
                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                Text(item.name)
            } else {
                Color.clear
                    .frame(width: 125, height: 125)
                    .background(Color.gray.opacity(0.3)) // 未入手アイテムの背景色
                Text("未入手")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct Collection: View {
    @ObservedObject var itemState: ItemState

    var body: some View {
        VStack {
            resetButton
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(Rarity.allCases) { rarity in
                        sectionView(for: rarity)
                    }
                }
                .frame(maxWidth: .infinity) // スクロールビューの横幅を最大にする
            }
        }
        .navigationTitle("My Collection")
    }

    // リセットボタンのビュー
    var resetButton: some View {
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
    }

    // セクションビューを生成するヘルパー関数
    func sectionView(for rarity: Rarity) -> some View {
        Section(header: Text(rarity.rawValue)
                    .font(.headline)
                    .padding()) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(itemState.ItemSources.filter { $0.rarity == rarity }) { item in
                    ItemView(item: item, isOwned: itemState.UserItems.contains(item.name))
                }
            }
        }
    }
}

// プレビュー用のコード
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Collection(itemState: ItemState())
    }
}
