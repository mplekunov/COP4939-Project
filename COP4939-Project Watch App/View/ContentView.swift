//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/8/23.
//

import SwiftUI
import CoreMotion
import Combine

struct ContentView: View {
    @State private var isRecording = false
    
    @StateObject var dataCollectorViewModel: DataCollectorViewModel = DataCollectorViewModel(
        deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.05),
        deviceLocationSensorModel: DeviceLocationSensorViewModel())
    
    @StateObject var dataSenderViewModel: DataSenderViewModel = DataSenderViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if isRecording && dataSenderViewModel.isReceiverConnected &&
                dataCollectorViewModel.isLocationAuthorized {
                NavigationView {
                    StatisticsView(isRecording: $isRecording)
                }
            } else {
                RecordingDataView
            }
        }
        .foregroundColor(.orange)
        .environmentObject(dataSenderViewModel)
        .environmentObject(dataCollectorViewModel)
    }
    
    var RecordingDataView: some View {
        Button("Start Recording") {
            if dataCollectorViewModel.startDataCollection() {
                dataSenderViewModel.startTransferringChannel()
                isRecording = true
            }
        }
        .padding()
    }
}

//#Preview {
//    ContentView(dataCollectorViewModel: StateObject(
//        wrappedValue: DataCollectorViewModel(
//            deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.01),
//            deviceLocationSensorModel: DeviceLocationSensorViewModel())),
//                dataSenderViewModel: StateObject(
//                    wrappedValue: DataSenderViewModel()))
//}
