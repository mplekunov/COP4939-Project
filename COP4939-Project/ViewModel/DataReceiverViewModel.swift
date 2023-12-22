//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import Combine

class DataReceiverViewModel : ObservableObject {
    @Published public private(set) var error: WatchConnectivityError?
    
    @Published public private(set) var session: WatchTrackingSession?
    
    @Published public private(set) var isSessionCompleted = false
    @Published public private(set) var isSessionInProgress = false
    @Published public private(set) var isSessionInfoReceived = false
    @Published public private(set) var isSessionDeliveryError = false
    
    private let logger: LoggerService
    
    private let converter = JSONConverter()
    
    private let watchConnectivityManager = WatchConnectivityManager.instance
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        
        watchConnectivityManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
        
        
        watchConnectivityManager.$message
            .receive(on: DispatchQueue.main)
            .compactMap { message in
                guard !message.isEmpty else { return nil }
                
                do {
                    let dataPacket = try self.converter.decode(DataPacket.self, from: message)
                    
                    switch dataPacket.dataType {
                    case .WatchSession:
                        self.logger.log(message: "Session info has been received")
                        self.isSessionInfoReceived = true
                        return try self.converter.decode(WatchTrackingSession.self, from: dataPacket.data)
                    case .WatchSessionStart:
                        self.logger.log(message: "Session is in progress")
                        self.isSessionInProgress = true
                    case .WatchSessionEnd:
                        self.logger.log(message: "Session is completed")
                        self.isSessionCompleted = true
                    case .WatchConnectivityError:
                        self.logger.log(message: "Error in watch connectivity")
                        self.isSessionDeliveryError = true
                    default:
                        self.logger.error(message: "DataType is not recognized")
                    }
                } catch {
                    self.logger.error(message: "\(error)")
                }
                
                return nil
            }
            .assign(to: &$session)
    }
    
    func setToDefault() {
        isSessionDeliveryError = false
        isSessionInProgress = false
        isSessionCompleted = false
        isSessionInfoReceived = false
        session = WatchTrackingSession()
    }
}
