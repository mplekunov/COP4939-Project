//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionView : View {
    @EnvironmentObject var locationSensorViewModel: DeviceLocationSensorViewModel
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel
    @StateObject private var cameraViewModel = CameraViewModel()
    
    @Binding var showSessionRecordingView: Bool
    @Binding var showSessionResultView: Bool
    
    var body: some View {
        VStack {
            if cameraViewModel.error != nil {
                Text("\(cameraViewModel.error.debugDescription)")
                    .foregroundStyle(.orange)
            } else {
                VideoRecordingView(image: cameraViewModel.frame)
                    .edgesIgnoringSafeArea(.all)
                    .padding()
            }
            
            Button("Stop Water Skiing Recording") {
                dataSenderViewModel.send(dataType: .WatchSessionEnd, data: Data())
                showSessionRecordingView.toggle()
                showSessionResultView.toggle()
            }
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}
