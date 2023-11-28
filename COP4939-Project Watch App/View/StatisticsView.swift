//
//  StatisticsView.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import SwiftUI
import Combine

struct StatisticsView: View {
    private var dataCollectorViewModel: StateObject<DataCollectorViewModel>
    private var dataSenderViewModel: StateObject<DataSenderViewModel>
    private var collectedDataSubscription: Cancellable?
    
    @Binding private var isRecording: Bool
    @Binding private var locationData: Array<Location>
    @Binding private var motionData: Array<MotionData>
    
    init(
        dataCollectorViewModel: StateObject<DataCollectorViewModel>,
        dataSenderViewModel: StateObject<DataSenderViewModel>,
        isRecording: Binding<Bool>
    ) {
        self.dataCollectorViewModel = dataCollectorViewModel
        self.dataSenderViewModel = dataSenderViewModel
        
        self._isRecording = isRecording
        self._locationData = dataCollectorViewModel.projectedValue.locationData
        self._motionData = dataCollectorViewModel.projectedValue.motionData
        
        // Sends data to the iPhone when CollectedData array of DataCollector is being updated with new data
        self.collectedDataSubscription = dataCollectorViewModel.wrappedValue.objectWillChange.sink {
            if let data = dataCollectorViewModel.wrappedValue.collectedData.last {
                dataSenderViewModel.wrappedValue.send(dataType: .WatchStatisticsData, data: data)
            }
        }
    }
    
    var body: some View {
        List {
            Section("Location Direction in Degrees") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Degrees: \(locationData.last?.directionInDegrees.formatted() ?? "N/A")")
                }
            }
            
            Section("Location Coordinates") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latitude: \(locationData.last?.coordinate.latitude.formatted() ?? "N/A")")
                    Text("Longitude: \(locationData.last?.coordinate.longitude.formatted() ?? "N/A")")
                }
            }
            
            Section("Attitude") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pitch: \(motionData.last?.attitude.pitch.formatted() ?? "N/A")")
                    Text("Yaw: \(motionData.last?.attitude.yaw.formatted() ?? "N/A")")
                    Text("Roll: \(motionData.last?.attitude.roll.formatted() ?? "N/A")")
                }
            }
            
            Section("G Force") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(motionData.last?.gForce.x.formatted() ?? "N/A")")
                    Text("Y: \(motionData.last?.gForce.y.formatted() ?? "N/A")")
                    Text("Z: \(motionData.last?.gForce.z.formatted() ?? "N/A")")
                }
            }
            
            Section("Acceleration") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(motionData.last?.acceleration.x.formatted() ?? "N/A")")
                    Text("Y: \(motionData.last?.acceleration.y.formatted() ?? "N/A")")
                    Text("Z: \(motionData.last?.acceleration.z.formatted() ?? "N/A")")
                }
            }
            
            HStack {
                Spacer()
                Button("Stop Recording") {
                    if isRecording {
                        dataCollectorViewModel.wrappedValue.stopDataCollection()
                        dataSenderViewModel.wrappedValue.stopTransferringChannel()
                        collectedDataSubscription?.cancel()
                        isRecording = false
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(.black)
        .foregroundColor(.orange)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    StatisticsView(
        dataCollectorViewModel: StateObject(
            wrappedValue: DataCollectorViewModel(
                deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.01),
                deviceLocationSensorModel: DeviceLocationSensorViewModel())),
        dataSenderViewModel: StateObject(
            wrappedValue: DataSenderViewModel(updateFrequency: 0.01)),
        isRecording: .constant(true)
    )
}
