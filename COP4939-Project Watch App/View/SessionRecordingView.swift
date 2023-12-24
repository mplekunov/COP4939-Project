//
//  SessionRecordingView.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI
import Combine

struct SessionRecordingView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    @StateObject private var dataCollectorViewModel: DataCollectorViewModel = DataCollectorViewModel(
        deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.05),
        deviceLocationSensorModel: DeviceLocationSensorViewModel())
    
    var body: some View {
        VStack {
            StatisticsView()
                .environmentObject(dataCollectorViewModel)
                .onReceive(dataCollectorViewModel.$isRecording, perform: { isRecording in
                    if !isRecording {
                        dataCollectorViewModel.startDataCollection()
                    }
                })
                .onReceive(sessionViewModel.$isEnded, perform: { isEnded in
                    if isEnded {
                        dataCollectorViewModel.stopDataCollection()
                        sessionViewModel.sendSession(session: WatchTrackingSession(uuid: UUID(), data: dataCollectorViewModel.trackingRecords))
                        dataCollectorViewModel.clear()
                    }
                })
        }
    }
}
