//
//  ContentView.swift
//  BetterRest
//
//  Created by Cathal Farrell on 06/04/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1.0

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false

    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 20.0){
                    Text("When do you want to wake up?")
                         .font(.headline)
                     DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                     .labelsHidden()
                         .datePickerStyle(WheelDatePickerStyle())//shows it on form layout
                }
                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Desired amount of sleep?")
                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    .accessibility(label: Text("\(sleepAmount, specifier: "%g") hours"))
                }

                VStack(alignment: .leading, spacing: 20.0) {
                    Text("Daily coffee intake?")
                        .font(.headline)
                    Stepper(value: $coffeeAmount, in: 1...20, step: 1){
                        if coffeeAmount == 1{
                            Text("1 cup")
                        }else {
                            Text("\(coffeeAmount, specifier: "%g") cups")
                        }
                    }
                    .accessibility(label: Text("\(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups")"))
                }

            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                //our button here
                Button(action: calculateBedTime) {
                    Text("Calculate")
                }
            )
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

        }
    }

    static var defaultWakeTime: Date {
        //Shows 07:00 by default on app launch
        var components = DateComponents()
        components.hour  = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    func calculateBedTime() {
        let model = SleepCalculator()

        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60

        do {
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: coffeeAmount)

            let sleepTime = wakeUp - prediction.actualSleep

            //to convert to nicely readable time:
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."

        } catch let err {

            print("Error: \(err)")

            alertTitle = "Error"
            alertMessage = "Sorry but something went wrong when calculating your bedtime."
        }

        isShowingAlert = true //to trigger alert
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
