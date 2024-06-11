//
//  Pre_Mission.swift
//  WakeMeUp
//
//  Created by 長井亮輔 on 2024/06/11.
//

import SwiftUI
import SwiftCSV // SwiftCSVをインポート

struct Pre_Mission: View {
    @State private var randomEntry: String = ""
    
    var body: some View {
        VStack {
            Text(randomEntry)
                .padding()
            
            Button(action: {
                randomEntry = loadRandomEntry()
            }) {
                Text("Load Random Entry")
            }
            .padding()
        }
        .onAppear {
            randomEntry = loadRandomEntry()
        }
    }
    
    func loadRandomEntry() -> String {
        guard let csvURL = Bundle.main.url(forResource: "TOEIC", withExtension: "csv") else {
            print("CSV file not found")
            return "Error: CSV file not found"
        }
        
        do {
            let csv = try CSV<Named>(url: csvURL)
            let entries = csv.columns?["entry"]
            return (entries ?? []).randomElement() ?? "No entries found"
        } catch {
            print("Error reading CSV file: \(error)")
            return "Error reading CSV file"
        }
    }
}

#Preview {
    Pre_Mission()
}
