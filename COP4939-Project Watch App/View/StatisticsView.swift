//
//  StatisticsView.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import SwiftUI
import Combine

struct StatisticsView: View {
    @EnvironmentObject var dataCollectorViewModel: DataCollectorViewModel
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel
    
    private let logger: LoggerService
    
    @Binding private var isRecording: Bool
    
    init(isRecording: Binding<Bool>) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self._isRecording = isRecording
    }
    
    var body: some View {
        List {
            Section("Location Direction in Degrees") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Degrees: \(dataCollectorViewModel.locations.last?.directionInDegrees.formatted() ?? "N/A")")
                }
            }
            
            Section("Location Coordinates") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latitude: \(dataCollectorViewModel.locations.last?.coordinate.latitude.formatted() ?? "N/A")")
                    Text("Longitude: \(dataCollectorViewModel.locations.last?.coordinate.longitude.formatted() ?? "N/A")")
                }
            }
            
            Section("Attitude") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pitch: \(dataCollectorViewModel.motions.last?.attitude.pitch.formatted() ?? "N/A")")
                    Text("Yaw: \(dataCollectorViewModel.motions.last?.attitude.yaw.formatted() ?? "N/A")")
                    Text("Roll: \(dataCollectorViewModel.motions.last?.attitude.roll.formatted() ?? "N/A")")
                }
            }
            
            Section("G Force") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(dataCollectorViewModel.motions.last?.gForce.x.formatted() ?? "N/A")")
                    Text("Y: \(dataCollectorViewModel.motions.last?.gForce.y.formatted() ?? "N/A")")
                    Text("Z: \(dataCollectorViewModel.motions.last?.gForce.z.formatted() ?? "N/A")")
                }
            }
            
            Section("Acceleration") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(dataCollectorViewModel.motions.last?.acceleration.x.formatted() ?? "N/A")")
                    Text("Y: \(dataCollectorViewModel.motions.last?.acceleration.y.formatted() ?? "N/A")")
                    Text("Z: \(dataCollectorViewModel.motions.last?.acceleration.z.formatted() ?? "N/A")")
                }
            }
            
            HStack {
                Spacer()
                Button("Stop Recording") {
                    if isRecording {
                        dataCollectorViewModel.stopDataCollection()
                        dataSenderViewModel.stopTransferringChannel()
                        
                        let session = Session(uuid: UUID(), data: dataCollectorViewModel.collectedData)
 
                        dataSenderViewModel.send(dataType: .WatchSession, data: session)
                        isRecording = false
                        dataCollectorViewModel.clearData()
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

//#Preview {
//    StatisticsView(
//        dataCollectorViewModel: StateObject(
//            wrappedValue: DataCollectorViewModel(
//                deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.01),
//                deviceLocationSensorModel: DeviceLocationSensorViewModel())),
//        dataSenderViewModel: StateObject(
//            wrappedValue: DataSenderViewModel()),
//        isRecording: .constant(true)
//    )
//}
