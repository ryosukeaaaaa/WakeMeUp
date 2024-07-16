//
//  Gacha.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/16.
//

import SwiftUI

struct Gacha: View {
    @ObservedObject var itemState = ItemState()
    @State private var resultItem: String? = nil
    @State private var showResult = false
    var body: some View {
        VStack{
            SpriteView(scene: GachaScene(size: CGSize(width: 300, height: 300)))
                .frame(width: 300, height: 300)
                .padding()
            HStack{
                Button(action: {
                    spinGacha()
                }) {
                    VStack{
                        Text("ノーマルガチャ")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Text("所持枚数: \(itemState.NormalCoin)")
                    }
                }
                Button(action: {
                    spinGacha()
                }) {
                    VStack{
                        Text("スペシャルガチャ")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Text("所持枚数: \(itemState.SpecialCoin)")
                    }
                }
            }
            
            if let resultItem = resultItem {
                Text("結果: \(resultItem)")
                    .font(.title)
                    .padding()
            }
        }
        .alert(isPresented: $showResult) {
            Alert(title: Text("ガチャ結果"), message: Text(resultItem ?? ""), dismissButton: .default(Text("OK")))
        }
    }
    func spinGacha() {
        // ガチャを回すロジックをここに追加
        // 結果を反映
        let items = itemState.ItemSources
        resultItem = items.randomElement()
        showResult = true
    }
}

import SpriteKit

class GachaScene: SKScene {
    private var handle: SKShapeNode!
    private var timer: Timer?

    override func didMove(to view: SKView) {
        backgroundColor = .white

        // ガチャボールを表示
        for _ in 0..<20 {
            let ball = SKShapeNode(circleOfRadius: 20)
            ball.fillColor = .random
            ball.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: size.height...size.height*1.5))
            ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            ball.physicsBody?.restitution = 0.6
            addChild(ball)
        }

        // ガチャポンの回転部分
        handle = SKShapeNode(rectOf: CGSize(width: 50, height: 10))
        handle.fillColor = .gray
        handle.position = CGPoint(x: size.width/2, y: size.height/2)
        handle.name = "handle"
        handle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 10))
        handle.physicsBody?.isDynamic = false
        addChild(handle)

        // Start the rotation
        startRotation()
    }

    override func update(_ currentTime: TimeInterval) {
        // 回転アニメーション
        if let handle = childNode(withName: "handle") {
            handle.zRotation += 0.1
        }
    }

    private func startRotation() {
        // Start the timer to release a capsule after a few seconds
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(releaseCapsule), userInfo: nil, repeats: false)
    }

    @objc private func releaseCapsule() {
        // Stop the rotation
        handle.removeAllActions()
        
        // Release a capsule
        if let capsule = children.filter({ $0 is SKShapeNode && $0 != handle }).randomElement() {
            capsule.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        }

        // Restart the rotation for the next round
        startRotation()
    }
}

extension SKColor {
    static var random: SKColor {
        return SKColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
    }
}

#Preview {
    Gacha()
}

