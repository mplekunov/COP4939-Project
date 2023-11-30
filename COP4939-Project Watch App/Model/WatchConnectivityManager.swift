//
//  WatchConnectivityManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager : NSObject, WCSessionDelegate, ObservableObject {
    @Published var message: Data = Data()
    
    @Published var isConnected: Bool = false
    
    private var logger: LoggerService
    
    private var session: WCSession = WCSession.default
    
    override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        session.delegate = self
        
        activateSession()
    }
    
    private func activateSession() {
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    func send(data: Data, replyHandler: @escaping (Data) -> Void) {
//        if !isReachable() {
//            logger.log(message: "Session is not reachable")
//            return
//        }
        
        session.sendMessageData(
            data,
            replyHandler: replyHandler,
            errorHandler: { [weak self] error in
                guard let self = self else { return }
                
                self.logger.error(message: "\(error)")
            }
        )
    }
    
    func send(data: Data) {
//        if !isReachable() {
//            logger.log(message: "Session is not reachable")
//            return
//        }
        
        logger.log(message: "Message is being sent")
        session.sendMessageData(
            data,
            replyHandler: nil,
            errorHandler: { [weak self] error in
                guard let self = self else { return }
                
                self.logger.error(message: "\(error)")
            }
        )
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.objectWillChange.send()
        }
        
        if activationState != .activated {
            logger.log(message: "Device has not been activated")
        } else if let error = error {
            logger.error(message: "\(error)")
        }
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.objectWillChange.send()
        }
    }
}
