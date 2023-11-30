//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dataReceiverViewModel: DataReceiverViewModel = DataReceiverViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if dataReceiverViewModel.isSessionInfoReceived {
                NavigationView {
                    StatisticsView()
                }
            } else {
                LoadingView()
            }
        }
        .foregroundColor(.orange)
        .environmentObject(dataReceiverViewModel)
    }
}

struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
        /* : uiView.stopAnimating()*/
    }
}

struct LoadingView: View {
    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionInProgress {
                        Text("Session in Progress...")
                        .font(.title)
                        .foregroundColor(.orange)
                } else if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionCompleted {
                        Text("Session has been Completed...")
                        .font(.title)
                        .foregroundColor(.orange)
                } else if dataReceiverViewModel.isDeviceConnected {
                    Text("Waiting for connection...")
                    .font(.title)
                    .foregroundColor(.orange)
                }
                
                ActivityIndicatorView()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .background(.black.opacity(0.5))
                    .cornerRadius(10)
            }
        }
    }
}
