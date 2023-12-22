//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionView : View {
    @EnvironmentObject var dataSenderViewModel: DataSenderViewModel
    @StateObject private var model = CameraViewModel()
    
    @Binding var showSessionRecordingView: Bool
    @Binding var showSessionResultView: Bool
    
    var body: some View {
        VStack {
            if model.error != nil {
                Text("\(model.error.debugDescription)")
                    .foregroundStyle(.orange)
            } else {
                VideoRecordingView(image: model.frame)
                    .edgesIgnoringSafeArea(.all)
                    .padding()
            }
            
            Button("Stop Water Skiing Recording") {
                dataSenderViewModel.send(dataType: .WatchSessionEnd, data: Data())
                showSessionRecordingView.toggle()
                showSessionResultView.toggle()
            }
            .frame(width: 300)
            .padding()
            .background(.orange)
            .foregroundStyle(.black)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}
