//
//  MainView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI
import Combine

struct MainView: View {
    
    @State private var alert: AlertInfo?
    @State private var showAlert = false
    
    @EnvironmentObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    @Binding var showCourseSetupView: Bool
    
    @State private var isSendingData = false
    
    var body: some View {
        VStack {
            Button(waterSkiingCourseViewModel.course != nil ? "Edit WaterSkiing Course Layout" : "Setup WaterSkiing Course Layout") {
                showCourseSetupView = true
            }
            .frame(width: 300)
            .padding()
            .background(.orange)
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(.black)
            
            Button(action: {
                sessionViewModel.startSession()
                isSendingData = true
            }, label: {
                if isSendingData {
                    ActivityIndicatorView()
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                } else {
                    Text(waterSkiingCourseViewModel.course != nil ? "Start WaterSkiing Recording" : "Recording Unavailable")
                }
            })
            .onReceive(sessionViewModel.$isStarted, perform: { isStarted in
                if isSendingData && isStarted {
                    cameraViewModel.startRecording()
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
            .foregroundStyle(waterSkiingCourseViewModel.course != nil  ? .black : .gray)
            .disabled(waterSkiingCourseViewModel.course == nil)
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
