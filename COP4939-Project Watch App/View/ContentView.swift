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
    
    private var dataCollectorViewModel: StateObject<DataCollectorViewModel>
    private var dataSenderViewModel: StateObject<DataSenderViewModel>
    
    init(
        dataCollectorViewModel: StateObject<DataCollectorViewModel>,
        dataSenderViewModel: StateObject<DataSenderViewModel>
    ) {
        self.dataCollectorViewModel = dataCollectorViewModel
        self.dataSenderViewModel = dataSenderViewModel
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if isRecording {
                NavigationView {
                    StatisticsView(dataCollectorViewModel: dataCollectorViewModel, dataSenderViewModel: dataSenderViewModel,  isRecording: $isRecording)
                }
            } else {
                RecordingDataView
            }
        }
        .foregroundColor(.orange)
    }
    
    var RecordingDataView: some View {
        Button("Start Recording") {
            if dataCollectorViewModel.wrappedValue.startDataCollection() {
                dataSenderViewModel.wrappedValue.startTransferringChannel()
                isRecording = true
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(dataCollectorViewModel: StateObject(
        wrappedValue: DataCollectorViewModel(
            deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.01),
            deviceLocationSensorModel: DeviceLocationSensorViewModel())),
                dataSenderViewModel: StateObject(
                    wrappedValue: DataSenderViewModel(updateFrequency: 0.01)))
}
