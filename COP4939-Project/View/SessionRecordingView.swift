//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionRecordingView : View {
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    @State private var isSendingData = false
    
    @State private var alert: AlertInfo?
    
    var body: some View {
        VStack {
            VideoRecordingView(image: cameraViewModel.frame)
                .edgesIgnoringSafeArea(.all)
                .padding()
            
            Button(action: {
                sessionViewModel.endSession()
                isSendingData = true
            }, label: {
                if isSendingData {
                    ActivityIndicatorView()
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                } else {
                    Text("Stop WaterSkiing Recording")
                }
            })
            .onReceive(sessionViewModel.$error, perform: { error in
                guard isSendingData else { return }
                
                if error != nil {
                    alert = AlertInfo(
                        id: .DataSender,
                        title: "Watch Connectivity Error",
                        message: "\(error?.description ?? "Something went wrong during sending request to the watch.")"
                    )
                    
                    isSendingData = false
                }
            })
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
            .alert(item: $alert, content: { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            })
        }
    }
}
