import SwiftUI
// 画像を変換する関数
func transformedImage(image: Image, size: CGSize, frameWidth: CGFloat, frameHeight: CGFloat, a: CGFloat, isBlack: Bool) -> some View {
    let scaledWidth = size.width / a
    let scaledHeight = size.height / a
    
    // 枠の中心を基準にオフセットを計算
    let offsetX = (frameWidth / a) - (1920 / (2 * a)) + (scaledWidth / 2)
    let offsetY = (frameHeight / a) - (1080 / (2 * a)) + (scaledHeight / 2)
    
    return image
        .resizable()
        .frame(width: scaledWidth, height: scaledHeight)
        .offset(x: offsetX, y: offsetY)
        .colorMultiply(isBlack ? .black : .white)  // isBlackがtrueの場合、画像を真っ黒にする
}

// メインのビュー
struct CollectionImage: View {
    @ObservedObject var itemState = ItemState() // ItemStateのインスタンスを作成
    @State private var a: Float = Float(1920 / UIScreen.main.bounds.width)
    
    var body: some View {
        ZStack {
            // 背景画像を枠の中心に配置
            transformedImage(image: Image("Back"), size: CGSize(width: 1920, height: 1080), frameWidth: 0, frameHeight: 0, a: CGFloat(a), isBlack: false)
            
            // 他の画像を指定の座標に配置
            transformedImage(image: Image("Pteranodon"), size: CGSize(width: 530, height: 530), frameWidth: -22, frameHeight: 20, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Pteranodon"))
            transformedImage(image: Image("Spinosaurus"), size: CGSize(width: 701, height: 701), frameWidth: 258, frameHeight: 97, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Spinosaurus"))
            transformedImage(image: Image("Eagle"), size: CGSize(width: 338, height: 338), frameWidth: 1278, frameHeight: -31, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Eagle"))
            transformedImage(image: Image("Tyrannosaurus"), size: CGSize(width: 738, height: 738), frameWidth: 1175, frameHeight: -8, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Tyrannosaurus"))
            transformedImage(image: Image("Triceratops"), size: CGSize(width: 605, height: 605), frameWidth: 758, frameHeight: 145, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Triceratops"))
            transformedImage(image: Image("Koala"), size: CGSize(width: 214, height: 214), frameWidth: 655, frameHeight: 488, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Koala"))
            transformedImage(image: Image("Deer"), size: CGSize(width: 456, height: 456), frameWidth: -15, frameHeight: 350, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Deer"))
            transformedImage(image: Image("Giraffe"), size: CGSize(width: 605, height: 605), frameWidth: 1111, frameHeight: 275, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Giraffe"))
            transformedImage(image: Image("Elephant"), size: CGSize(width: 605, height: 605), frameWidth: 1329, frameHeight: 372, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Elephant"))
            transformedImage(image: Image("Rhinoceros"), size: CGSize(width: 499, height: 499), frameWidth: 141, frameHeight: 328, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Rhinoceros"))
            transformedImage(image: Image("Zebra"), size: CGSize(width: 423, height: 413), frameWidth: -27, frameHeight: 529, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Zebra"))
            transformedImage(image: Image("Lion"), size: CGSize(width: 415, height: 415), frameWidth: 310, frameHeight: 425, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Lion"))
            transformedImage(image: Image("Camel"), size: CGSize(width: 486, height: 486), frameWidth: 1016, frameHeight: 431, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Camel"))
            transformedImage(image: Image("Ostrich"), size: CGSize(width: 386, height: 386), frameWidth: 686, frameHeight: 481, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Ostrich"))
            transformedImage(image: Image("Hippo"), size: CGSize(width: 499, height: 499), frameWidth: 1000, frameHeight: 504, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Hippo"))
            transformedImage(image: Image("Bear"), size: CGSize(width: 367, height: 367), frameWidth: 958, frameHeight: 522, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Bear"))
            transformedImage(image: Image("Panda"), size: CGSize(width: 338, height: 338), frameWidth: 825, frameHeight: 613, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Panda"))
            transformedImage(image: Image("Tapir"), size: CGSize(width: 366, height: 336), frameWidth: 1482, frameHeight: 615, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Tapir"))
            transformedImage(image: Image("Turtle"), size: CGSize(width: 191, height: 191), frameWidth: 1612, frameHeight: 822, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Turtle"))
            transformedImage(image: Image("Sheep"), size: CGSize(width: 296, height: 296), frameWidth: 1426, frameHeight: 698, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Sheep"))
            transformedImage(image: Image("Pig"), size: CGSize(width: 318, height: 318), frameWidth: 1178, frameHeight: 686, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Pig"))
            transformedImage(image: Image("Crocodile"), size: CGSize(width: 354, height: 354), frameWidth: 1009, frameHeight: 720, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Crocodile"))
            transformedImage(image: Image("Tiger"), size: CGSize(width: 399, height: 399), frameWidth: 109, frameHeight: 569, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Tiger"))
            transformedImage(image: Image("Cheetah"), size: CGSize(width: 386, height: 386), frameWidth: 223, frameHeight: 589, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Cheetah"))
            transformedImage(image: Image("Gorilla"), size: CGSize(width: 367, height: 367), frameWidth: 442, frameHeight: 552, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Gorilla"))
            transformedImage(image: Image("Kangal"), size: CGSize(width: 366, height: 366), frameWidth: 625, frameHeight: 599, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Kangal"))
            transformedImage(image: Image("Raccoon"), size: CGSize(width: 224, height: 224), frameWidth: -15, frameHeight: 752, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Raccoon"))
            transformedImage(image: Image("Capybara"), size: CGSize(width: 198, height: 198), frameWidth: 90, frameHeight: 780, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Capybara"))
            transformedImage(image: Image("Owl"), size: CGSize(width: 119, height: 119), frameWidth: 249, frameHeight: 855, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Owl"))
            transformedImage(image: Image("Meerkat"), size: CGSize(width: 214, height: 214), frameWidth: 1726, frameHeight: 772, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Meerkat"))
            transformedImage(image: Image("Fox"), size: CGSize(width: 198, height: 198), frameWidth: 367, frameHeight: 766, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Fox"))
            transformedImage(image: Image("Duck"), size: CGSize(width: 162, height: 162), frameWidth: 487, frameHeight: 798, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Duck"))
            transformedImage(image: Image("Mice"), size: CGSize(width: 149, height: 149), frameWidth: 367, frameHeight: 844, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Mice"))
            transformedImage(image: Image("Goat"), size: CGSize(width: 258, height: 258), frameWidth: 534, frameHeight: 717, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Goat"))
            transformedImage(image: Image("Chick"), size: CGSize(width: 99, height: 99), frameWidth: 493, frameHeight: 897, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Chick"))
            transformedImage(image: Image("Squirrel"), size: CGSize(width: 126, height: 126), frameWidth: 555, frameHeight: 883, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Squirrel"))
            transformedImage(image: Image("Wolf"), size: CGSize(width: 318, height: 318), frameWidth: 718, frameHeight: 659, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Wolf"))
            transformedImage(image: Image("Dog"), size: CGSize(width: 198, height: 198), frameWidth: 683, frameHeight: 816, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Dog"))
            transformedImage(image: Image("Cat"), size: CGSize(width: 198, height: 198), frameWidth: 843, frameHeight: 822, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Cat"))
            transformedImage(image: Image("Monkey"), size: CGSize(width: 191, height: 191), frameWidth: 1424, frameHeight: 822, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Monkey"))
            transformedImage(image: Image("Penguin"), size: CGSize(width: 191, height: 191), frameWidth: 1073, frameHeight: 822, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Penguin"))
            transformedImage(image: Image("Rabbit"), size: CGSize(width: 171, height: 171), frameWidth: 996, frameHeight: 846, a: CGFloat(a), isBlack: !itemState.UserItems.contains("Rabbit"))
        }
        .frame(width: CGFloat(1920 / a), height: CGFloat(1080 / a))
        .border(Color.blue, width: 3)
    }
}

// プレビュー
struct CollectionImage_Previews: PreviewProvider {
    static var previews: some View {
        CollectionImage()
    }
}
