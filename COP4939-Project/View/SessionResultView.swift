//
//  SessionResultView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct SessionResultView : View {
    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
    
    @Binding var showSessionResultView: Bool
    
    var body: some View {
        if dataReceiverViewModel.isSessionInfoReceived {
            VStack {
                Text("Session Stats")
                    .foregroundStyle(.orange)
                    .padding()
                
                StatisticsView()
                    .environmentObject(dataReceiverViewModel)
                    .padding()
                
                Button("Close") {
                    showSessionResultView.toggle()
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
    
    struct ActivityIndicatorView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIActivityIndicatorView {
            UIActivityIndicatorView(style: .large)
        }
        
        func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
            uiView.startAnimating()
        }
    }
}
