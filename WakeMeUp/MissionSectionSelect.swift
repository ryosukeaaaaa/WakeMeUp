import SwiftUI

struct SectionSelectionView: View {
    let material: String
    let sectionCount: Int
    @Binding var isPresented: Bool
    @Binding var selectedSection: Int
    @Binding var reset: Bool
    @State private var isPreMissionPresented: Bool = false
    @State private var alarmStore = AlarmStore()

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<sectionCount + 1, id: \.self) { section in
                        Button(action: {
                            selectedSection = section
                            isPreMissionPresented = true
                        }) {
                            HStack {
                                Image(systemName: "flag")
                                Text(section == 0 ? "全範囲" : "セクション \(section)")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(section == 0 ? Color.blue : Color.cyan)  // 条件付きで背景色を設定
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
        .navigationDestination(isPresented: $isPreMissionPresented) {
            Pre_Mission(fromHome: true, material: material, reset: $reset, alarmStore: alarmStore, selectedSection: selectedSection)
                .navigationBarBackButtonHidden(true)
        }
    }
}

