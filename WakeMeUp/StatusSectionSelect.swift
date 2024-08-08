import SwiftUI

struct StatusSectionSelectView: View {
    let material: String
    let sectionCount: Int
    @Binding var isPresented: Bool
    @Binding var selectedSection: Int
    @State private var isNormalWordViewPresented: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<sectionCount + 1, id: \.self) { section in
                        Button(action: {
                            selectedSection = section
                            isNormalWordViewPresented = true
                        }) {
                            HStack {
                                Image(systemName: "flag")
                                Text(section == 0 ? "全範囲" : "セクション \(section)")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 1.2, green: 0.8, blue: 0.1))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            Spacer()
            AdMobView()
                .frame(width: 450, height: 90)
        }
        .padding()
        .navigationTitle("全\(sectionCount)セクション")
        .navigationDestination(isPresented: $isNormalWordViewPresented) {
            NormalWordView(material: material, selectedSection: selectedSection)
        }
    }
}

