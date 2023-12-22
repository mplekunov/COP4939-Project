//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionRecordingView : View {
    @EnvironmentObject var locationSensorViewModel: DeviceLocationSensorViewModel
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    @Binding var showSessionRecordingView: Bool
    @Binding var showSessionResultView: Bool
    
    @State private var showAlert = false
    @State private var isSendingData = false
    
    var body: some View {
        VStack {
            VideoRecordingView(image: cameraViewModel.frame)
                .edgesIgnoringSafeArea(.all)
                .padding()
            
            Button("Stop Water Skiing Recording") {
                dataSenderViewModel.send(dataType: .WatchSessionEnd, data: Data())
            }
            .onReceive(dataSenderViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    showAlert = true
                } else {
                    showSessionRecordingView.toggle()
                    showSessionResultView.toggle()
                }
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("\(dataSenderViewModel.error?.description ?? "Something went wrong during sending request to the watch.")")
                )
            }
        }
    }
}
