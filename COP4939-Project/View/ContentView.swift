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
    @State private var showSessionRecordingView: Bool = false
    @State private var showSessionResultView: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if sessionViewModel.isStarted {
                SessionRecordingView()
                    .environmentObject(cameraViewModel)
                    .environmentObject(sessionViewModel)
                    .onAppear(perform: {
                        cameraViewModel.startRecording()
                    })
                    .onDisappear(perform: {
                        cameraViewModel.stopRecording()
                    })
            } else if showCourseSetupView {
                WaterSkiingCourseSetupView(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(waterSkiingCourseViewModel)
            } else if sessionViewModel.isReceived {
                SessionResultView(recordedFile: cameraViewModel.recordedFile)
                    .environmentObject(sessionViewModel)
            } else {
                MainView(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(cameraViewModel)
                    .environmentObject(waterSkiingCourseViewModel)
                    .environmentObject(sessionViewModel)
            }
        }
    }
    
    /**
     1. Send Session Start to Watch.
     2. Send Session Stop when session needs to be stopped.
     3. When session began recording, start recording video.
     4. When Session has been ended, end recording of the video. AVFoundation framework
     5. Use the start date of video recording to synchronize video with data.
     6. When video has been synchronized, show the data of the session :
     6.a. Data should have information in the format described in slack.
     6.b. Buoy, Wake Cross, Gate should be clickable. Meaning when I FF or FB video, the data table should highlight point of the data that the video is currently represents.
     6.b.a. So, we have additional 2 points between each point of interest that should be highlighted, could simply highlight border of the row to show that.
     */
}
