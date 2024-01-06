//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionRecordingView : View {
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    @State private var isSendingData = false
    
    @State private var alert: AlertInfo?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
//            VideoRecordingView(image: cameraViewModel.frame)
//                .edgesIgnoringSafeArea(.all)
//                .padding()
            
            CameraPreviewView(captureSession: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
                .padding()
            
            Button(action: {
                sessionViewModel.endSession()
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
            .onReceive(cameraViewModel.$error, perform: { error in
                if error != nil {
                    alert = AlertInfo(
                        id: .Camera,
                        title: "Camera Error",
                        message: "\(error ?? "Something went wrong when app tried to record video from camera.")"
                    )
                    
                    showAlert = true
                }
            })
            .onReceive(sessionViewModel.$isEnded, perform: { isEnded in
                if isEnded {
                    print("The camera has stopped recording")
                    cameraViewModel.stopRecording()
                }
            })
            .onReceive(sessionViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    alert = AlertInfo(
                        id: .DataSender,
                        title: "Watch Connectivity Error",
                        message: "\(error ?? "Something went wrong during sending request to the watch.")"
                    )
                 
                    showAlert = true
                    
                    isSendingData = false
                }
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
            .alert(
                alert?.title ?? "",
                isPresented: $showAlert,
                actions: {
                    Button("Ok") {
                        showAlert = false
                    }
                },
                message: {
                    Text(alert?.message ?? "")
                }
            )
        }
    }
}
