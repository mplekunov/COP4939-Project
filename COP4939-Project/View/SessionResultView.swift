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
    
    @State var alert: AlertInfo?
    
    var body: some View {
        ZStack {
            if sessionViewModel.isReceived {
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
            } else {
                VStack {
                    Text("Session has been Completed. Awaiting session results to be received.")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    ActivityIndicatorView()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                        .background(.black.opacity(0.5))
                        .cornerRadius(10)
                }
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
