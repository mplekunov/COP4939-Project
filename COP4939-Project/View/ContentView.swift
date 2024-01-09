//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var waterSkiingCourseViewModel = WaterSkiingCourseViewModel<Double>(courseFileName: "Course_From_Video.txt")
    @StateObject var sessionViewModel = BaseSessionViewModel()
    @StateObject var cameraViewModel = CameraViewModel()
    @StateObject var videoViewModel = VideoViewModel()
    
    @State private var showResultsView = false
    @State private var showCourseSetupView = false

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
            } else if showResultsView {
                PassSessionResultView(waterSkiingCourseViewModel: waterSkiingCourseViewModel, cameraViewModel: cameraViewModel, sessionViewModel: sessionViewModel, showResultsView: $showResultsView)
                    .environmentObject(sessionViewModel)
            }  else if sessionViewModel.isReceived && cameraViewModel.videoFile != nil {
                WaterSkiingCourseSetupFromVideoView(showResultsView: $showResultsView)
                    .environmentObject(waterSkiingCourseViewModel)
                    .environmentObject(videoViewModel)
                    .onAppear(perform: {
                        guard let videoFile = cameraViewModel.videoFile else { return }
                        videoViewModel.startPlayback(video: videoFile)
                    })
            } else {
                MainViewWithoutLocation(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(cameraViewModel)
                    .environmentObject(waterSkiingCourseViewModel)
                    .environmentObject(sessionViewModel)
            }
        }
    }
}
