//
//  test.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/06/10.
//

import SwiftUI

struct test: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.largeTitle)
                .padding()
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.yellow)
            Button(action: {
                print("Button tapped")
            }) {
                Text("Tap me!")
            }
            .padding()
        }
    }
}

#Preview {
    test()
}
