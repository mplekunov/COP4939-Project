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
    
    private let converter: JSONConverter = JSONConverter()
    
    private var isDeviceConnectedSubscription: AnyCancellable?
    private var messageSubscription: AnyCancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        isDeviceConnectedSubscription = watchConnectivityManager.$isConnected.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                isDeviceConnected = self.watchConnectivityManager.isConnected
            }
        }
        
        messageSubscription = watchConnectivityManager.$message.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                decodeReceivedMessage(message: self.watchConnectivityManager.message)
            }
        }
    }
    
    private func decodeReceivedMessage(message: DataPacket?) {
        if let message = message {
            do {
                switch message.dataType {
                case .WatchSession:
                    logger.log(message: "Session info has been received")
                    session = try converter.decode(Session.self, from: message.data)
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
