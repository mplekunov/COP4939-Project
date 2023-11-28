//
//  WatchConnectivityManager.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager : NSObject, WCSessionDelegate, ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isVerified: Bool = false
    
    private var session: WCSession
    
    override init() {
        session = WCSession.default
        super.init()
        session.delegate = self
    }
    
    func connectToDevice() throws {
        if session.activationState != .activated {
            session.activate()
        }
        
        if isConnected {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let verificationData = try encoder.encode(PairingVerification(isVerified: true))
            let dataPacket = try encoder.encode(DataPacket(dataType: DataType.WatchPairingData, data: verificationData))
            
            session.sendMessageData(
                dataPacket,
                replyHandler: { data in
                    do {
                        print("Are we even fucking here?!")
                        let replyData = try decoder.decode(PairingVerification.self, from: data)
                        
                        self.isVerified = replyData.isVerified
                    } catch {
                        print("Internal Error: \(error)")
                    }
                },
                errorHandler: {
                    (error) in
                    print("Internal Error Send Message: \(error)")
                }
            )
        }
    }
    
    func send<T>(dataType: DataType, data: T) throws where T : Encodable {
        if !isConnected {
            throw WatchConnectivityError.ConnectionNotActivated
        }
        
        if !isVerified {
            throw WatchConnectivityError.DeviceNotVerified
        }
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(data)
            
            let dataPacket = try encoder.encode(DataPacket(dataType: dataType, data: data))
            
            session.sendMessageData(
                dataPacket,
                replyHandler: nil,
                errorHandler: {
                    (error) in
                    print("Internal Error: \(error)")
                }
            )
        } catch {
            throw JsonError.EncodingError
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
            print("Internal Error inside Activation Session: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.objectWillChange.send()
        }
    }
}
