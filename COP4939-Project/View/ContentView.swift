//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var waterSkiingCourseViewModel = WaterSkiingCourseViewModel()
    @StateObject var sessionViewModel = SessionViewModel()
    @StateObject var cameraViewModel = CameraViewModel()
    
    @State private var showCourseSetupView: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if sessionViewModel.isStarted {
                SessionRecordingView()
                    .environmentObject(cameraViewModel)
                    .environmentObject(sessionViewModel)
            } else if showCourseSetupView {
                WaterSkiingCourseSetupView(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(waterSkiingCourseViewModel)
            } else if sessionViewModel.isReceived {
                PassSessionResultView(waterSkiingCourseViewModel: waterSkiingCourseViewModel, cameraViewModel: cameraViewModel, sessionViewModel: sessionViewModel)
                    .environmentObject(sessionViewModel)
            } else {
                MainView(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(cameraViewModel)
                    .environmentObject(waterSkiingCourseViewModel)
                    .environmentObject(sessionViewModel)
            }
        }
    }
}
