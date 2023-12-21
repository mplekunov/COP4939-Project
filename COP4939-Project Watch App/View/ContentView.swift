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
    @StateObject var dataSenderViewModel: DataSenderViewModel = DataSenderViewModel()
    @StateObject var dataReceiverViewModel: DataReceiverViewModel = DataReceiverViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if dataReceiverViewModel.isSessionInProgress {
                SessionRecordingView()
                    .environmentObject(dataReceiverViewModel)
                    .environmentObject(dataSenderViewModel)
            } else {
                Text("Waiting for session to start recording")
                    .foregroundStyle(.orange)
            }
        }
        .foregroundColor(.orange)
    }
}
