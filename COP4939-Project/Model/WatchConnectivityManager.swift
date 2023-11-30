//
//  WatchConnectivityManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager : NSObject, WCSessionDelegate, ObservableObject {
    private var logger: LoggerService
    
    private var session: WCSession = WCSession.default
    
    @Published var message: Data = Data()
    
    @Published var isConnected: Bool = false
    
    override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        session.delegate = self
        
        activateSession()
    }
    
    private func activateSession() {
        isConnected = session.activationState != .notActivated
        
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    private func isPaired() -> Bool {
        return session.isPaired
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.log(message: "Session is inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.log(message: "Session is deactivated")
        
        activateSession()
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
        
        session.sendMessageData(
            data,
            replyHandler: nil,
            errorHandler: { [weak self] error in
                guard let self = self else { return }
                
                self.logger.error(message: "\(error)")
            }
        )
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        logger.log(message: "Message without reply has been received")
        
        DispatchQueue.main.async {
            self.message = messageData
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        logger.log(message: "Message with replyHandler has been received")
        
        DispatchQueue.main.async {
            self.message = messageData
        }
        
        replyHandler(Data())
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
