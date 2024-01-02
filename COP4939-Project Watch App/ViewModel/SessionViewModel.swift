//
//  SessionViewModel.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 12/23/23.
//

import Foundation
import Combine

class SessionViewModel : ObservableObject {
    private let logger: LoggerService
    
    private var converter: JSONConverter = JSONConverter()
    private let watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager.instance
    
    @Published public private(set) var error: String?
    
    private var messageSubscriber: AnyCancellable?
    
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
        
        messageSubscriber = watchConnectivityManager.$message.sink { message in
            guard !message.isEmpty else { return }
            
            do {
                let dataPacket = try self.converter.decode(DataPacket.self, from: message)
                
                self.clear()
                
                switch dataPacket.dataType {
                case .WatchSession:
                    self.isReceived = true
                case .WatchSessionStart:
                    self.send(dataPacket: DataPacket(dataType: .WatchSessionStart, id: UUID(), data: Data()))
                    self.isStarted = true
                case .WatchSessionEnd:
                    self.send(dataPacket: DataPacket(dataType: .WatchSessionEnd, id: UUID(), data: Data()))
                    self.isEnded = true
                default:
                    self.logger.error(message: "DataType is not recognized")
                }
            } catch {
                self.logger.error(message: "\(error)")
            }
        }
    }
    
    func sendSession(session: WatchTrackingSession) {
        do {
            sendAsFile(dataPacket: DataPacket(dataType: .WatchSession, id: UUID(), data: try converter.encode(session)))
        } catch {
            logger.error(message: "\(error)")
        }
    }
    
    private func send(dataPacket: DataPacket) {
        do {
            watchConnectivityManager.sendAsString(
                data: try converter.encode(dataPacket),
                replyHandler: nil,
                errorHandler:  { [weak self] error in
                    guard let self = self else { return }
                    
                    logger.log(message: "\(error)")
                }
            )
        } catch {
            logger.error(message: "\(error)")
        }
    }
    
    private func sendAsFile(dataPacket: DataPacket) {
        do {
            watchConnectivityManager.sendAsFile(data: try converter.encode(dataPacket))
        } catch {
            logger.error(message: "\(error)")
        }
    }
    
    private func clear() {
        error = nil
        self.isEnded = false
        self.isStarted = false
        self.isReceived = false
    }
}
