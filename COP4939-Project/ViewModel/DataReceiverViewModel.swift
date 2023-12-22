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
    @Published var isSessionDeliveryError: Bool = false
    
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
                
                isDeviceConnected = self.watchConnectivityManager.isConnected
                objectWillChange.send()
            }
        }
        
        messageSubscription = watchConnectivityManager.$message.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                decodeReceivedMessage(message: watchConnectivityManager.message)
                objectWillChange.send()
            }
        }
    }
    
    private func decodeReceivedMessage(message: Data) {
        if !message.isEmpty {
            do {
                let dataPacket = try converter.decode(DataPacket.self, from: message)
                
                switch dataPacket.dataType {
                case .WatchSession:
                    logger.log(message: "Session info has been received")
                    session = try converter.decode(WatchTrackingSession.self, from: dataPacket.data)
                    isSessionInfoReceived = true
                    isSessionCompleted = false
                    isSessionInProgress = false
                    isSessionDeliveryError = false
                case .WatchSessionStart:
                    isSessionInfoReceived = false
                    logger.log(message: "Session is in progress")
                    isSessionInProgress = true
                    isSessionCompleted = false
                    isSessionInfoReceived = false
                    isSessionDeliveryError = false
                case .WatchSessionEnd:
                    logger.log(message: "Session is completed")
                    isSessionInProgress = false
                    isSessionCompleted = true
                    isSessionInfoReceived = false
                    isSessionDeliveryError = false
                case .WatchConnectivityError:
                    logger.log(message: "Error in watch connectivity")
                    isSessionDeliveryError = true
                    isSessionInProgress = false
                    isSessionCompleted = false
                    isSessionInfoReceived = false
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
