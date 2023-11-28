//
//  COP4939_ProjectApp.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 11/27/23.
//

import SwiftUI

@main
struct COP4939_Project_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(dataCollectorViewModel: StateObject(
                wrappedValue: DataCollectorViewModel(
                    deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.05),
                    deviceLocationSensorModel: DeviceLocationSensorViewModel())),
                        dataSenderViewModel: StateObject(wrappedValue: DataSenderViewModel(updateFrequency: 0.5)))
        }
    }
}
