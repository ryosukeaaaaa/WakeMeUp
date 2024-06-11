//
//  Pre_Mission.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/06/11.
//

import SwiftUI
import SwiftCSV

struct Pre_Mission: View {
    @State private var randomEntry: (String, String, String) = ("", "", "")
    
    var body: some View {
        VStack {
            Spacer() // 上部スペース
            Text(randomEntry.0)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10) // 下部に少し余白を追加
            Text(randomEntry.1)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Text(randomEntry.2)
                .font(.headline)//subheadline)
                .multilineTextAlignment(.center)
                .padding()
            Spacer() // 下部スペース
            
            Button(action: {
                randomEntry = loadRandomEntry()
            }) {
                Text("次の単語")
            }
            .padding()
        }
        .onAppear {
            randomEntry = loadRandomEntry()
        }
    }
    
    func loadRandomEntry() -> (String, String, String) {
        guard let csvURL = Bundle.main.url(forResource: "TOEIC", withExtension: "csv") else {
            print("CSV file not found")
            return ("Error", "CSV file not found", "")
        }
        
        do {
            let csv = try CSV<Named>(url: csvURL)
            if let entries = csv.columns?["entry"] as? [String],
               let meanings = csv.columns?["meaning"] as? [String],
               let examples = csv.columns?["example_sentence"] as? [String] {
                let combinedEntries = zip(zip(entries, meanings), examples).map { ($0.0, $0.1, $1) }
                if let randomElement = combinedEntries.randomElement() {
                    return randomElement
                } else {
                    return ("No entries found", "", "")
                }
            } else {
                return ("No entries found", "", "")
            }
        } catch {
            print("Error reading CSV file: \(error)")
            return ("Error", "reading CSV file", "")
        }
    }
}

#Preview {
    Pre_Mission()
}
