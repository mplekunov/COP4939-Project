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
    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel

    @StateObject private var dataCollectorViewModel: DataCollectorViewModel = DataCollectorViewModel(
        deviceMotionSensorModel: DeviceMotionSensorViewModel(updateFrequency: 0.05),
        deviceLocationSensorModel: DeviceLocationSensorViewModel())
    
    private var isSessionEnded: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            dataReceiverViewModel.$isDeviceConnected,
            dataReceiverViewModel.$isSessionCompleted
        )
        .map { $0.0 && $0.1}
        .eraseToAnyPublisher()
    }
    
    @State private var isSessionInfoSend: Bool = false
    
    var body: some View {
        VStack {
            StatisticsView()
                .environmentObject(dataCollectorViewModel)
                .onReceive(dataCollectorViewModel.$isRecording, perform: { isRecording in
                    if !isRecording {
                        dataCollectorViewModel.startDataCollection()
                    }
                })
                .onReceive(isSessionEnded, perform: { isEnded in
                    if isEnded && !isSessionInfoSend {
                        sendSessionToReceiver()
                        isSessionInfoSend.toggle()
                    }
                })
        }
    }
    
    private func sendSessionToReceiver() {
        dataCollectorViewModel.stopDataCollection()
        
        let session = WatchTrackingSession(uuid: UUID(), data: dataCollectorViewModel.trackingRecords)
        dataSenderViewModel.send(dataType: .WatchSession, data: session)
        
        dataCollectorViewModel.clearData()
    }
}
