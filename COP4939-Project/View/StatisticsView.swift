//
//  StatisticsView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import SwiftUI

struct StatisticsView: View {
    private var dataReceiverViewModel: StateObject<DataReceiverViewModel>
    
    @Binding private var collectedData: Array<CollectedData>
    @State private var lastCollectedData: CollectedData?
    
    init(
        dataReceiverViewModel: StateObject<DataReceiverViewModel>
    ) {
        self.dataReceiverViewModel = dataReceiverViewModel
        _collectedData = dataReceiverViewModel.projectedValue.collectedData
    }
    
    var body: some View {
        List {
            Section("Location Direction in Degrees") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Degrees: \(collectedData.last?.locationData.directionInDegrees.formatted() ?? "N/A")")
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Location Coordinates") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latitude: \(collectedData.last?.locationData.coordinate.latitude.formatted() ?? "N/A")")
                    Text("Longitude: \(collectedData.last?.locationData.coordinate.longitude.formatted() ?? "N/A")")
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Attitude") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pitch: \(collectedData.last?.motionData.attitude.pitch.formatted() ?? "N/A")")
                    Text("Yaw: \(collectedData.last?.motionData.attitude.yaw.formatted() ?? "N/A")")
                    Text("Roll: \(collectedData.last?.motionData.attitude.roll.formatted() ?? "N/A")")
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("G Force") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(collectedData.last?.motionData.gForce.x.formatted() ?? "N/A")")
                    Text("Y: \(collectedData.last?.motionData.gForce.y.formatted() ?? "N/A")")
                    Text("Z: \(collectedData.last?.motionData.gForce.z.formatted() ?? "N/A")")
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Acceleration") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("X: \(collectedData.last?.motionData.acceleration.x.formatted() ?? "N/A")")
                    Text("Y: \(collectedData.last?.motionData.acceleration.y.formatted() ?? "N/A")")
                    Text("Z: \(collectedData.last?.motionData.acceleration.z.formatted() ?? "N/A")")
                }
            }
            .listRowBackground(Color.secondary)
        }
        .padding()
        .background(.black)
        .foregroundColor(.orange)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    StatisticsView(dataReceiverViewModel: StateObject(
        wrappedValue: DataReceiverViewModel(updateFrequency: 0.05)))
}
