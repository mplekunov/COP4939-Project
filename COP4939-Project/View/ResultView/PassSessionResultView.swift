//
//  SessionResultView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct PassSessionResultView : View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    @StateObject var waterSkiingPassVideoManager = WaterSkiingPassVideoViewModel()
    @StateObject var waterSkiingPassViewModel: WaterSkiingPassViewModel
    
    @State var alert: AlertInfo?
    
    init(
        waterSkiingCourseViewModel: WaterSkiingCourseViewModel,
        cameraViewModel: CameraViewModel,
        sessionViewModel: SessionViewModel
    ) {
       _waterSkiingPassViewModel = StateObject(wrappedValue: WaterSkiingPassViewModel(
            waterSkiingCourseViewModel: waterSkiingCourseViewModel,
            cameraViewModel: cameraViewModel,
            sessionViewModel: sessionViewModel
        ))
    }
    
    var body: some View {
        ZStack {
            VStack {
                PassStatisticsView()
                    .environmentObject(waterSkiingPassViewModel)
                    .environmentObject(waterSkiingPassVideoManager)
                    .padding()
                
                Button("Close") {
                    sessionViewModel.clear()
                }
                .frame(width: 300)
                .padding()
                .background(.orange)
                .foregroundStyle(.black)
                .clipShape(.rect(cornerRadius: 20))
            }
        }
        .onReceive(waterSkiingPassViewModel.$pass, perform: { pass in
            guard let pass = pass else { return }
            
            waterSkiingPassVideoManager.startPlayback(pass: pass)
        })
        .onReceive(sessionViewModel.$error, perform: { error in
            guard error == nil else { return }
            
            if error != nil {
                alert = AlertInfo(
                    id: .DataReceiver,
                    title: "",
                    message: "\(error ?? "Something went wrong during receiving request from the watch.")"
                )
            }
        })
    }
}
