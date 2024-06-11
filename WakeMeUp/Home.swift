import SwiftUI

struct Home: View {
    @State private var alarms: [AlarmData] = [
        AlarmData(time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                  repeatLabel: "毎日",
                  mission: "ミッションなし",
                  isOn: true)
    ]
    @State private var showingAddAlarmView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if alarms.isEmpty {
                    Text("No Alarms")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach($alarms) { $alarm in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(alarm.repeatLabel)
                                    Text(alarm.time, style: .time)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Text(alarm.mission)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Toggle("", isOn: $alarm.isOn)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                        }
                        .onDelete(perform: deleteAlarm)
                    }
                }
            }
            .navigationBarTitle("Alarms")
            .navigationBarItems(trailing: Button(action: {
                showingAddAlarmView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            .sheet(isPresented: $showingAddAlarmView) {
                AlarmEditView(alarms: $alarms)
            }
            .padding()
        }
    }
    
    private func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}



#Preview {
    Home()
}
