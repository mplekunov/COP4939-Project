//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import Combine

class DataReceiverViewModel : ObservableObject {
    @Published var error: WatchConnectivityError?
    
    @Published var isSessionCompleted = false
    @Published var isSessionInProgress = false
    @Published var isSessionInfoReceived = false
    @Published var isSessionDeliveryError = false
    
    @Published var session = WatchTrackingSession()
    
    private let logger: LoggerService
    
    private let converter = JSONConverter()
    
    private var isDeviceConnectedSubscription: AnyCancellable?
    private var messageSubscription: AnyCancellable?
    
    private let watchConnectivityManager = WatchConnectivityManager.instance
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        isDeviceConnectedSubscription = watchConnectivityManager.$error.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                error = self.watchConnectivityManager.error
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
                case .WatchSession:
                    logger.log(message: "Session info has been received")
                    session = try converter.decode(WatchTrackingSession.self, from: dataPacket.data)
                    isSessionInfoReceived = true
                case .WatchSessionStart:
                    logger.log(message: "Session is in progress")
                    isSessionInProgress = true
                case .WatchSessionEnd:
                    logger.log(message: "Session is completed")
                    isSessionCompleted = true
                case .WatchConnectivityError:
                    logger.log(message: "Error in watch connectivity")
                    isSessionDeliveryError = true
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
    
    func setToDefault() {
        isSessionDeliveryError = false
        isSessionInProgress = false
        isSessionCompleted = false
        isSessionInfoReceived = false
        session = WatchTrackingSession()
    }
}
