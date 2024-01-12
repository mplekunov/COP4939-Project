//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI
import AVFoundation

struct SessionRecordingView : View {
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var sessionViewModel: BaseSessionViewModel
    
    @State private var isSendingData = false
    
    @State private var alert: AlertInfo?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            if (cameraViewModel.session != nil) {
                CameraPreviewView(captureSession: cameraViewModel.session)
                    .edgesIgnoringSafeArea(.all)
                    .padding()
                
                Button(action: {
                    sessionViewModel.endSession()
                    isSendingData = true
                }, label: {
                    if isSendingData {
                        ActivityIndicatorView(color: .black)
                            .cornerRadius(10)
                    } else {
                        Text("Stop WaterSkiing Recording")
                    }
                })
                .onReceive(cameraViewModel.$error, perform: { error in
                    guard let error = error else { return }
                    
                    alert = AlertInfo(
                        id: .Camera,
                        title: "Camera Error",
                        message: "\(error)"
                    )
                    
                    showAlert = true
                })
                .onReceive(sessionViewModel.$isEnded, perform: { isEnded in
                    if isEnded {
                        cameraViewModel.stopRecording()
                    }
                })
                .onReceive(sessionViewModel.$error, perform: { error in
                    guard isSendingData else { return }
                    guard let error = error else { return }
                    
                    alert = AlertInfo(
                        id: .DataSender,
                        title: "Watch Connectivity Error",
                        message: "\(error)"
                    )
                    
                    showAlert = true
                    isSendingData = false
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
            } else {
                ActivityIndicatorView(color: .orange)
                    .cornerRadius(20)
            }
        }
    }
}
