//
//  WatchConnectivityManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import WatchConnectivity
import Compression

class WatchConnectivityManager : NSObject, WCSessionDelegate, ObservableObject {
    private static var instance: WatchConnectivityManager = WatchConnectivityManager()
    
    @Published var message: Data = Data()
    
    @Published var isConnected: Bool = false
    
    private var logger: LoggerService
    
    private var session: WCSession = WCSession.default
    
    private let JSON_FILE_EXTENSION = ".json"
    
    private override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        session.delegate = self
        
        activateSession()
    }
    
    static func getInstance() -> WatchConnectivityManager {
        return WatchConnectivityManager.instance
    }
    
    private func activateSession() {
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    private func writeDataToFile(data: Data) throws -> URL {
        let temporaryDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + JSON_FILE_EXTENSION
        let fileUrl = temporaryDir.appendingPathComponent(fileName)
        
        try data.write(to: fileUrl, options: .atomic)
        
        return fileUrl
    }
    
    func sendAsFile(data: Data, errorHandler: @escaping (Error) -> Void) {
        if !isReachable() {
            logger.log(message: "Session is not reachable")
            return
        }
        
        do {
            let fileUrl = try writeDataToFile(data: data)
            
            session.transferFile(fileUrl, metadata: nil)
        } catch {
            errorHandler(error)
        }
    }
    
    func sendAsString(data: Data, replyHandler: ((Data) -> Void)?, errorHandler: @escaping (Error) -> Void) {
        if !isReachable() {
            logger.log(message: "Session is not reachable")
            return
        }
        
        do {
            let compressedData = try (data as NSData).compressed(using: .lzma)
            
            logger.log(message: "\(compressedData.length)")
            logger.log(message: "\(data.count)")
            
            session.sendMessageData(
                compressedData as Data,
                replyHandler: replyHandler,
                errorHandler: errorHandler
            )
        } catch {
            logger.error(message: "\(error)")
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        logger.log(message: "File has been sent")
        logger.log(message: "Outstanding file transfers: \(WCSession.default.outstandingFileTransfers)")
        logger.log(message: "Has content pending: \(WCSession.default.hasContentPending)")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        logger.log(message: "MessageData without replyHandler has been received")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let decompressedData = try (messageData as NSData).decompressed(using: .lzma)
                
                message = decompressedData as Data
            } catch {
                logger.error(message: "\(error.localizedDescription)")
            }
            
            objectWillChange.send()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        logger.log(message: "MessageData with replyHandler has been received")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let decompressedData = try (messageData as NSData).decompressed(using: .lzma)
                
                message = decompressedData as Data
            } catch {
                logger.error(message: "\(error)")
            }
            
            objectWillChange.send()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        logger.log(message: "Message without replyHandler has been received")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                if let first = message.first,
                    let data = first.value as? NSData {
                    
                    let decompressedData = try data.decompressed(using: .lzma)
                    
                    self.message = decompressedData as Data
                }
            } catch {
                logger.error(message: "\(error.localizedDescription)")
            }
            
            objectWillChange.send()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        logger.log(message: "Message with replyHandler has been received")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                if let first = message.first,
                    let data = first.value as? NSData {
                    
                    let decompressedData = try data.decompressed(using: .lzma)
                    
                    self.message = decompressedData as Data
                }
            } catch {
                logger.error(message: "\(error.localizedDescription)")
            }
            
            objectWillChange.send()
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
