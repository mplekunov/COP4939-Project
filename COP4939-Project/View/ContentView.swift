//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording: Bool = false
    
    private var dataReceiverViewModel: StateObject<DataReceiverViewModel>
    
    init(
        dataReceiverViewModel: StateObject<DataReceiverViewModel>
    ) {
        self.dataReceiverViewModel = dataReceiverViewModel
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if dataReceiverViewModel.wrappedValue.isPaired && dataReceiverViewModel.wrappedValue.isSessionInProgress {
                NavigationView {
                    StatisticsView(dataReceiverViewModel: dataReceiverViewModel)
                }
            } else {
                RecordingDataView
            }
        }
        .foregroundColor(.orange)
    }
    
    var RecordingDataView: some View {
        VStack {
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    dataReceiverViewModel.wrappedValue.startTransferringChannel()
                } else {
                    dataReceiverViewModel.wrappedValue.stopTransferringChannel()
                }
            }) {
                Text(isRecording ? "Stop Receiving Data" : "Start Receiving Data")
                    .padding()
                    .background(Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    ContentView(dataReceiverViewModel: StateObject(
        wrappedValue: DataReceiverViewModel(updateFrequency: 0.05)))
}
