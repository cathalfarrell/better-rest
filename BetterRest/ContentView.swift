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
    @State private var coffeeAmountInt = 1

    //Computed using Model
    var suggestedBedtime: String {

        let model = SleepCalculator()

        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60

        do {
            /* // Using Stepper
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: coffeeAmount)
            */
            // Using Picker
            let coffeeIntake = Double(coffeeAmountInt+1)
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: coffeeIntake)
            let sleepTime = wakeUp - prediction.actualSleep

            //to convert to nicely readable time:
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            return formatter.string(from: sleepTime)

        } catch let err {

            print("Error: \(err)")

            return "Error"
        }

    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")){
                     DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                     .labelsHidden()
                         .datePickerStyle(WheelDatePickerStyle())//shows it on form layout
                }
                .font(.headline)

                Section(header: Text("Desired amount of sleep?")){
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                .font(.headline)

                /*
                Challenge 2 - Picker binding needs to be an Int
                Replace the “Number of cups” stepper with a Picker showing the same range of values.
                */

                Section(header: Text("Daily coffee intake? - Picker")){
                    Picker("Number of cups", selection: $coffeeAmountInt) {
                        ForEach(0..<20) {
                            if $0 > 0 {
                                Text("\($0+1) cups")
                            } else {
                                Text("1 cup")
                            }

                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                }
                .font(.headline)

                Section(header: Text("Suggested Bedtime")){
                   Text(suggestedBedtime)
                }
                .font(.headline)
            }
            .navigationBarTitle("BetterRest")
        }
    }

    static var defaultWakeTime: Date {
        //Shows 07:00 by default on app launch
        var components = DateComponents()
        components.hour  = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
