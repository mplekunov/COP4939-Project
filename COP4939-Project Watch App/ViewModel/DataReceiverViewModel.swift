//
//  DataReceiverViewModel.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import Combine

class DataReceiverViewModel : ObservableObject {
    @Published var isDeviceConnected: Bool = false
    @Published var isSessionCompleted: Bool = false
    @Published var isSessionInProgress: Bool = false
    
    @Published var session: WatchTrackingSession = WatchTrackingSession()
    
    private let logger: LoggerService
    
    private let converter: JSONConverter = JSONConverter()
    
    private var isDeviceConnectedSubscription: AnyCancellable?
    private var messageSubscription: AnyCancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager.getInstance()
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        isDeviceConnectedSubscription = watchConnectivityManager.$isConnected.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                isDeviceConnected = watchConnectivityManager.isConnected
            }
        }
        
        messageSubscription = watchConnectivityManager.$message.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                decodeReceivedMessage(message: watchConnectivityManager.message)
            }
        }
    }
    
    private func decodeReceivedMessage(message: Data) {
        if !message.isEmpty {
            do {
                let dataPacket = try converter.decode(DataPacket.self, from: message)
                
                switch dataPacket.dataType {
                case .WatchSessionStart:
                    logger.log(message: "Session is in progress")
                    isSessionInProgress = true
                    isSessionCompleted = false
                case .WatchSessionEnd:
                    logger.log(message: "Session is completed")
                    isSessionInProgress = false
                    isSessionCompleted = true
                default:
                    logger.error(message: "DataType is not recognized")
                }
            } catch {
                logger.error(message: "Couldn't decode message -> \(error)")
            }
        } else {
            logger.log(message: "Empty message has been received")
        }
    }
}
