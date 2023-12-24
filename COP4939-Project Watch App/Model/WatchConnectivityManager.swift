//
//  WatchConnectivityManager.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/23/23.
//

import Foundation

import Foundation
import WatchConnectivity
import Compression

class WatchConnectivityManager : NSObject, ObservableObject {
    static let instance = WatchConnectivityManager()
    
    @Published var message: Data = Data()
    @Published var error: WatchConnectivityError?
    
    private let logger: LoggerService
    
    private var session: WCSession = WCSession.default
    
    private let JSON_FILE_EXTENSION = ".json"
    
    private override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        
        configure()
        checkConnectionStatus()
    }
    
    private func configure() {
        session.delegate = self
    }
    
    private func set(error: WatchConnectivityError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.error = error
        }
    }
    
    private func checkConnectionStatus() {
        switch session.activationState {
        case .notActivated:
            set(error: .DeviceNotActivated)
            session.activate()
        case .inactive:
            set(error: .DeviceNotActive)
            session.activate()
        case .activated:
            set(error: nil)
            break
        @unknown default:
            set(error: .UnknownStatus)
        }
    }
    
    private func checkDeviceStatus() -> Bool {
        if !session.isReachable {
            logger.log(message: "Session is not reachable")
            set(error: .DeviceNotReachable)
        }
        
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
        if !checkDeviceStatus() {
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
        if !checkDeviceStatus() {
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
}

extension WatchConnectivityManager : WCSessionDelegate {
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        logger.log(message: "File has been received")
        
        if !FileManager.default.fileExists(atPath: file.fileURL.path()) {
            logger.error(message: "File Doesn't exist at specified location ~ \(file.fileURL.path())")
        } else {
            if let jsonData = FileManager.default.contents(atPath: file.fileURL.path()) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    message = jsonData
                }
            } else {
                logger.error(message: "File is empty")
            }
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
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        checkConnectionStatus()
    }
}
