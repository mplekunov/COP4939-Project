//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import Combine

class DataSenderViewModel : ObservableObject {
    @Published var isPaired: Bool = false
    
    private var shouldStopConnecting = false
    private var operationQueue: OperationQueue = OperationQueue()
    private var updateFrequency: Double
    
    private var watchConnectivityManagerSubscription: Cancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    init(updateFrequency: Double) {
        operationQueue.maxConcurrentOperationCount = 1
        
        self.updateFrequency = updateFrequency
        
        watchConnectivityManagerSubscription = watchConnectivityManager.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            self.isPaired = watchConnectivityManager.isConnected && watchConnectivityManager.isVerified
        }
    }
    
    private func connectToDevice() {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            while !self.isPaired && !self.shouldStopConnecting {
                print("Internal Log: Trying to connect to device")
                
                print("is Paired: \(self.isPaired)")
                
                do {
                    try self.watchConnectivityManager.connectToDevice()
                } catch {
                    print("Internal Error: \(error)")
                }
                
                Thread.sleep(forTimeInterval: self.updateFrequency)
            }
            
            self.send(dataType: .WatchStatisticsData, data: CollectedData(sessionStart: true))
        }
    }
    
    func startTransferringChannel() {
        connectToDevice()
        shouldStopConnecting = false
    }
    
    func stopTransferringChannel() {
        operationQueue.cancelAllOperations()
        shouldStopConnecting = true
        
        send(dataType: .WatchStatisticsData, data: CollectedData(sessionEnd: true))
    }

    func send<T>(dataType: DataType, data: T) where T : Encodable {
        do {
            try watchConnectivityManager.send(dataType: dataType, data: data)
        } catch {
            print("Internal Error: \(error)")
        }
    }
}
