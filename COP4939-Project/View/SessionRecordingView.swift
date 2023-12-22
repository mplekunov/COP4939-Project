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
    
    @State private var isSendingData = false
    
    @State private var alert: AlertInfo?
    
    var body: some View {
        VStack {
            VideoRecordingView(image: cameraViewModel.frame)
                .edgesIgnoringSafeArea(.all)
                .padding()
            
            Button(action: {
                isSendingData = true
            }, label: {
                if isSendingData {
                    ActivityIndicatorView()
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                } else {
                    Text("Stop WaterSkiing Recording")
                }
            })
            .onReceive(dataSenderViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    alert = AlertInfo(
                        id: .DataSender,
                        title: "Watch Connectivity Error",
                        message: "\(error?.description ?? "Something went wrong during sending request to the watch.")"
                    )
                    
                    isSendingData = false
                } else {
                    dataSenderViewModel.send(dataType: .WatchSessionEnd, data: Data())
                    showSessionRecordingView = false
                    showSessionResultView = true
                }
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
            .alert(item: $alert, content: { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            })
        }
    }
}
