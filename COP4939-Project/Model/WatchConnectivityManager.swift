//
//  WatchConnectivityManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager : NSObject, WCSessionDelegate, ObservableObject {
    private var operationQueue = OperationQueue()
    
    private var session: WCSession
    
    @Published var collectedData: CollectedData = CollectedData()
    
    @Published var isConnected: Bool = false
    @Published var isVerified: Bool = false
    
    override init() {
        session = WCSession.default
        super.init()
        session.delegate = self
    }
    
    func connectToDevice() throws {
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Internal Log: Session is Inactive")
        
        do {
            try connectToDevice()
        } catch {
            print("Internal Error: \(error)")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Internal Log: Session is Deactivated")
        
        do {
            try connectToDevice()
        } catch {
            print("Internal Error: \(error)")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.objectWillChange.send()
        }
        
        if activationState != .activated {
            print("Internal Error: Device has not been activated")
            
        } else if let error = error {
            print("Internal Error: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.objectWillChange.send()
        }
    }
    
    func send<T>(dataType: DataType, data: T) throws where T : Encodable {
        try connectToDevice()
        
        let packetData = try getDataToSend(dataType: dataType, data: data)
        
        session.sendMessageData(
            packetData,
            replyHandler: nil,
            errorHandler: {
                (error) in
                print("Internal Error: \(error)")
            }
        )
    }
    
    private func getDataToSend<T>(dataType: DataType, data: T) throws -> Data where T : Encodable {
        do {
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(data)
            return try encoder.encode(DataPacket(dataType: dataType, data: data))
        } catch {
            throw JsonError.EncodingError
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        let decoder = JSONDecoder()
        
        do {
            let dataPacket = try decoder.decode(DataPacket.self, from: messageData)
            
            print("Watch send something")
            
            switch dataPacket.dataType {
            case .WatchStatisticsData:
                self.collectedData = try decoder.decode(CollectedData.self, from: dataPacket.data)
            case .WatchPairingData:
                // Sends Reply to the device confirming both devices are paired
                try replyHandler(getDataToSend(dataType: .WatchPairingData, data: dataPacket.data))
                
                let pairingData = try decoder.decode(PairingVerification.self, from: dataPacket.data)
                
                self.isVerified = pairingData.isVerified
            }
        } catch {
            print("Internal Error: \(error)")
        }
    }
}
