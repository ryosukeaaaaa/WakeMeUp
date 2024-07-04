//
//  HomeMission.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/03.
//

import SwiftUI

struct HomeMission: View {
    @State private var basic = false
    @State private var toeic = false
    @State private var business = false
    @State private var academic = false
    @StateObject private var missionState = MissionState()
    
    var body: some View {
        VStack(spacing: 10) {
            NavigationStack {
                Button(action: {
                    basic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("基礎英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $basic) {
                    Pre_Mission(fromHome: true, material: "基礎英単語", reset: $basic)// trueにすることで目覚ましと区別
                }
                
                Button(action: {
                    toeic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("TOEIC英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $toeic) {
                    Pre_Mission(fromHome: true, material: "TOEIC英単語", reset: $toeic)// trueにすることで目覚ましと区別
                }
            
                Button(action: {
                    business = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("ビジネス英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $business) {
                    Pre_Mission(fromHome: true, material: "ビジネス英単語", reset: $business)// trueにすることで目覚ましと区別
                }
            
                Button(action: {
                    academic = true
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("学術英単語")
                            .font(.headline)
                        Spacer()  // ここにSpacerを追加
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)  // 横幅を最大に設定
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationDestination(isPresented: $academic) {
                    Pre_Mission(fromHome: true, material: "学術英単語", reset: $academic)// trueにすることで目覚ましと区別
                }
            }
        }
        .padding()
        .onAppear {
            print("aaaadaf")
            basic = false
            toeic = false
            business = false
            academic = false
        }
    }
}


#Preview {
    HomeMission()
}
