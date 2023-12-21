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
    
    @Binding var showSessionRecordingView: Bool
    @Binding var showSessionResultView: Bool
    
    var body: some View {
        VStack {
            VideoRecordingView()
                .padding()
            
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
