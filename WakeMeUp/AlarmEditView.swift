import SwiftUI

struct AlarmEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var alarms: [AlarmData]
    @State private var time = Date()
    @State private var repeatLabel = "一回限り"
    @State private var mission = "ミッションなし"
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Alarm Time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                
                Section(header: Text("Repeat")) {
                    Picker("Repeat", selection: $repeatLabel) {
                        Text("一回限り").tag("一回限り")
                        Text("平日").tag("平日")
                        Text("週末").tag("週末")
                        Text("毎日").tag("毎日")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Mission")) {
                    TextField("Mission", text: $mission)
                }
                
                Button(action: {
                    let newAlarm = AlarmData(time: time, repeatLabel: repeatLabel, mission: mission, isOn: true)
                    alarms.append(newAlarm)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            }
            .navigationBarTitle("New Alarm", displayMode: .inline)
        }
    }
}

struct AlarmEditView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmEditView(alarms: .constant([]))
    }
}



