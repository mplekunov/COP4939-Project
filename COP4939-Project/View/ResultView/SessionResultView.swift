//
//  SessionResultView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionResultView : View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var recordedFile: URL?
    
    @State var alert: AlertInfo?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Session Stats")
                    .foregroundStyle(.orange)
                    .padding()
                
                StatisticsView()
                    .environmentObject(sessionViewModel)
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
