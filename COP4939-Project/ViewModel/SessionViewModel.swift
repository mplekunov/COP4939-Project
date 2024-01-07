//
//  WatchConnectivityViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/23/23.
//

import Foundation
import Combine

class BaseSessionViewModel : ObservableObject {
    private let logger: LoggerService
    
    private var converter: JSONConverter = JSONConverter()
    private let watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager.instance
    
    @Published public private(set) var error: String?
    @Published public private(set) var session: WatchTrackingSession?
    
    @Published public private(set) var isEnded = false
    @Published public private(set) var isStarted = false
    @Published public private(set) var isReceived = false
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))

        watchConnectivityManager.$error
            .receive(on: DispatchQueue.main)
            .compactMap { error in
                guard let error = error else { return nil }
                
                return error.description
            }
            .assign(to: &$error)
        
        watchConnectivityManager.$message
            .receive(on: DispatchQueue.main)
            .compactMap { message in
                guard !message.isEmpty else { return nil }
                
                self.clear()
                
                do {
                    let dataPacket = try self.converter.decode(DataPacket.self, from: message)
                    
                    switch dataPacket.dataType {
                    case .WatchSession:
                        self.isReceived = true
                        return try self.converter.decode(WatchTrackingSession.self, from: dataPacket.data)
                    case .WatchSessionStart:
                        self.isStarted = true
                    case .WatchSessionEnd:
                        self.isEnded = true
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
    
    func startSession() {
        send(dataPacket: DataPacket(dataType: .WatchSessionStart, id: UUID(), data: Data()))
    }
    
    func endSession() {
        send(dataPacket: DataPacket(dataType: .WatchSessionEnd, id: UUID(), data: Data()))
    }
    
    private func send(dataPacket: DataPacket) {
        do {
            watchConnectivityManager.sendAsString(
                data: try converter.encode(dataPacket),
                replyHandler: nil,
                errorHandler:  { [weak self] error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.error = error.localizedDescription
                    }
                    
                    logger.log(message: "\(error)")
                }
            )
        } catch {
            self.error = error.localizedDescription
            logger.error(message: "\(error)")
        }
    }
    
    func clear() {
        session = nil
        error = nil
        self.isEnded = false
        self.isStarted = false
        self.isReceived = false
    }
}
