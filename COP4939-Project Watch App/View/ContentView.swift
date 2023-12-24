//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/8/23.
//

import SwiftUI
import CoreMotion
import Combine

struct ContentView: View {
    @StateObject var sessionViewModel = SessionViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if sessionViewModel.isStarted {
                SessionRecordingView()
                    .environmentObject(sessionViewModel)
            } else {
                Text("Waiting for session to start recording")
                    .foregroundStyle(.orange)
            }
        }
        .foregroundColor(.orange)
    }
}
