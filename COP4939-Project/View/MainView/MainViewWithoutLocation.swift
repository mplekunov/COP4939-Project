//
//  MainViewWithoutLocation.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import SwiftUI
import Combine

struct MainViewWithoutLocation : View {
    @State private var alert: AlertInfo?
    @State private var showAlert = false
    
    @EnvironmentObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel<WaterSkiingCourseFromVideo>
    @EnvironmentObject var sessionViewModel: BaseSessionViewModel
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    @Binding var showCourseSetupView: Bool
    
    @State private var isSendingData = false
    
    var body: some View {
        VStack {
            Button(action: {
                cameraViewModel.startRecording()
                isSendingData = true
            }, label: {
                if isSendingData {
                    ActivityIndicatorView()
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                } else {
                    Text("Start Recording")
                }
            })
            .onReceive(cameraViewModel.$isRecording, perform: { isRecording in
                guard let isRecording = isRecording else { return }
                if isSendingData && isRecording {
                    sessionViewModel.startSession()
                }
            })
            .onReceive(cameraViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    alert = AlertInfo(
                        id: .Camera,
                        title: "Camera Error",
                        message: "\(error ?? "Something went wrong when app tried to access camera.")"
                    )
                    
                    showAlert = true
                    isSendingData = false
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
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(.black)
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
