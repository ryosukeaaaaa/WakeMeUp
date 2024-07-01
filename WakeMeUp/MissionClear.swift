//
//  MissionClear.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/07/02.
//

import SwiftUI

struct MissionClear: View {
    @State private var HomeView = false
    var body: some View {
        VStack {
            Text("ミッション完了")
                .font(.largeTitle)
                .padding()
            Text("おめでとうございます！")
                .font(.title)
            Button(action: {
                HomeView = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("ホームへ")
                        .font(.headline)
                }
                .padding(10)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationDestination(isPresented: $HomeView) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    MissionClear()
}
