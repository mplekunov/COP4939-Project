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
    
    private let converter: JSONConverter = JSONConverter()
    
    private var session: WCSession = WCSession.default
    
    @Published var message: DataPacket?
    
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
    
    func send(data: DataPacket, replyHandler: ((Data) -> Void)?, errorHandler: @escaping (Error) -> Void) {
        if !isReachable() {
            logger.log(message: "Session is not reachable")
            return
        }
        
        do {
            session.sendMessageData(
                try converter.encode(data),
                replyHandler: replyHandler,
                errorHandler: errorHandler
            )
        } catch {
            logger.error(message: "\(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        logger.log(message: "Message without reply has been received")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                message = try converter.decode(DataPacket.self, from: messageData)
            } catch {
                logger.error(message: "\(error)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        logger.log(message: "Message with replyHandler has been received")
        
        var dataPacket: DataPacket?
        
        do {
            dataPacket = try converter.decode(DataPacket.self, from: messageData)
            
            if let dataPacket = dataPacket {
                let deliveryInformation = DeliveryInformation(messageID: dataPacket.id, isDelivered: true)
                let data = try converter.encode(deliveryInformation)
                
                replyHandler(try converter.encode(DataPacket(dataType: .DataDeliveryInformation, id: UUID(), data: data)))
            }
        } catch {
            logger.error(message: "\(error)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
                
            if let dataPacket = dataPacket {
                message = dataPacket
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            isConnected = false
            objectWillChange.send()
        }
        
        if activationState != .activated {
            logger.log(message: "Device has not been activated")
        } else if let error = error {
            logger.error(message: "\(error)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            isConnected = true
            objectWillChange.send()
        }
    }
}
