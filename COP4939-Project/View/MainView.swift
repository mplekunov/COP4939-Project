//
//  MainView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct MainView: View {
    @EnvironmentObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel
    
    @Binding var showCourseSetupView: Bool
    @Binding var showSessionRecordingView: Bool
    
    @State private var showAlert = false
    @State private var isSendingData = false
    
    var body: some View {
        VStack {
            Button(waterSkiingCourseViewModel.course != nil ? "Edit WaterSkiing Course Layout" : "Setup WaterSkiing Course Layout") {
                showCourseSetupView.toggle()
            }
            .frame(width: 300)
            .padding()
            .background(.orange)
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(.black)
            
            Button(waterSkiingCourseViewModel.course != nil  ? "Start WaterSkiing Recording" : "Recording Unavailable") {
                dataSenderViewModel.send(dataType: .WatchSessionStart, data: Data())
                isSendingData = true
            }
            .onReceive(dataSenderViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    showAlert = true
                } else {
                    showSessionRecordingView.toggle()
                }
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(waterSkiingCourseViewModel.course != nil  ? .black : .gray)
            .disabled(waterSkiingCourseViewModel.course == nil)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("\(dataSenderViewModel.error?.description ?? "Something went wrong during sending request to the watch.")")
                )
            }
        }
    }
}
