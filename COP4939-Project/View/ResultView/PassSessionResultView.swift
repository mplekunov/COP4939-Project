//
//  SessionResultView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct PassSessionResultView : View {
    @EnvironmentObject var sessionViewModel: BaseSessionViewModel
    
    @StateObject var waterSkiingPassVideoViewModel = WaterSkiingPassVideoViewModel<Double>()
    @StateObject var waterSkiingPassViewModel: WaterSkiingPassViewModel
    
    @State var alert: AlertInfo?
    @State var showAlert = false
    @Binding var showResultsView: Bool
    
    init(
        waterSkiingCourseViewModel: WaterSkiingCourseViewModel<WaterSkiingCourseFromVideo>,
        cameraViewModel: CameraViewModel,
        sessionViewModel: BaseSessionViewModel,
        showResultsView: Binding<Bool>
    ) {
       _waterSkiingPassViewModel = StateObject(wrappedValue: WaterSkiingPassViewModel(
            waterSkiingCourseViewModel: waterSkiingCourseViewModel,
            cameraViewModel: cameraViewModel,
            sessionViewModel: sessionViewModel
        ))
        
        self._showResultsView = showResultsView
    }
    
    var body: some View {
        ZStack {
            VStack {
                PassStatisticsView<Double>()
                    .environmentObject(waterSkiingPassViewModel)
                    .environmentObject(waterSkiingPassVideoViewModel)
                    .padding()
                
                Button("Close") {
                    sessionViewModel.clear()
                    showResultsView = false
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
            
            waterSkiingPassVideoViewModel.startPlayback(pass: pass)
        })
        .onReceive(sessionViewModel.$error, perform: { error in
            guard error == nil else { return }
            
            if error != nil {
                alert = AlertInfo(
                    id: .DataReceiver,
                    title: "",
                    message: "\(error ?? "Something went wrong during receiving request from the watch.")"
                )
                
                showAlert = true
            }
        })
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
