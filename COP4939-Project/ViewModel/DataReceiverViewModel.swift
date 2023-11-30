//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import Combine

class DataReceiverViewModel : ObservableObject {
    @Published var isDeviceConnected: Bool = false
    @Published var isSessionCompleted: Bool = false
    @Published var isSessionInProgress: Bool = false
    @Published var isSessionInfoReceived: Bool = false
    @Published var session: Session = Session()
    
    private let logger: LoggerService
    
    private var isDeviceConnectedSubscription: AnyCancellable?
    private var messageSubscription: AnyCancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        isDeviceConnectedSubscription = watchConnectivityManager.$isConnected.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isDeviceConnected = self.watchConnectivityManager.isConnected
            }
        }
        
        messageSubscription = watchConnectivityManager.$message.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.decodeReceivedMessage(message: self.watchConnectivityManager.message)
            }
        }
    }
    
    private func decodeReceivedMessage(message: Data) {
        let decoder = JSONDecoder()
        
        if message.isEmpty {
            logger.log(message: "Empty message has been received")
            return
        }
        
        do {
            let dataPacket = try decoder.decode(DataPacket.self, from: message)
            
            logger.log(message: "\(dataPacket.dataType)")
            
            switch dataPacket.dataType {
            case .WatchSession:
                logger.log(message: "Session info has been received")
                session = try decoder.decode(Session.self, from: dataPacket.data)
                isSessionInfoReceived = true
            case .WatchSessionStart:
                isSessionInfoReceived = false
                logger.log(message: "Session is in progress")
                isSessionInProgress = true
                isSessionCompleted = false
            case .WatchSessionEnd:
                logger.log(message: "Session is not in progress")
                isSessionInProgress = false
                isSessionCompleted = true
            }
        } catch {
            logger.error(message: "Couldn't decode message -> \(error)")
        }
        
    }
}
