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
                cameraViewModel.startRecording()
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
                    
                    isSendingData = false
                }
                
                alert = nil
            })
            .onReceive(sessionViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    alert = AlertInfo(
                        id: .DataSender,
                        title: "Watch Connectivity Error",
                        message: "\(error ?? "Something went wrong during sending request to the watch.")"
                    )
                    
                    isSendingData = false
                }
                
                alert = nil
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(waterSkiingCourseViewModel.course != nil  ? .black : .gray)
            .disabled(waterSkiingCourseViewModel.course == nil)
            .alert(item: $alert, content: { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            })
        }
    }
}
