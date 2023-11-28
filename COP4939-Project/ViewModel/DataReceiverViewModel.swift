//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import Combine

class DataReceiverViewModel : ObservableObject {
    @Published var isPaired: Bool = false
    @Published var isSessionInProgress: Bool = false
    @Published var collectedData: Array<CollectedData> = Array()
    @Published var sessions: Dictionary<String, Array<CollectedData>> = Dictionary()
    
    private var shouldStopConnecting = false
    private var operationQueue: OperationQueue = OperationQueue()
    private var updateFrequency: Double
    private var watchConnectivitySubscription: Cancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    init(updateFrequency: Double) {
        operationQueue.maxConcurrentOperationCount = 1
        self.updateFrequency = updateFrequency
        
        
        watchConnectivitySubscription = watchConnectivityManager.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            isPaired = self.watchConnectivityManager.isConnected
            
            let data = self.watchConnectivityManager.collectedData
            
            isSessionInProgress = data.sessionStart == nil
            
            collectedData.append(data)
            
            if data.sessionEnd == true {
                let uuid = UUID().uuidString
                sessions[uuid] = collectedData
                collectedData = Array()
            }
        }
    }
    
    private func connectToDevice() {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            while !self.isPaired && !self.shouldStopConnecting {
                print("Internal Log: Trying to connect to device")
                
                do {
                    try self.watchConnectivityManager.connectToDevice()
                } catch {
                    print("Internal Error: \(error)")
                }
                
                Thread.sleep(forTimeInterval: self.updateFrequency)
            }
        }
    }
    
    func startTransferringChannel() {
        connectToDevice()
        shouldStopConnecting = false
    }
    
    func stopTransferringChannel() {
        operationQueue.cancelAllOperations()
        shouldStopConnecting = true
    }
}
