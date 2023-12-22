//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import Combine

class DataSenderViewModel : ObservableObject {
    private let logger: LoggerService
    
    private let converter: JSONConverter = JSONConverter()
    
    private var watchConnectivityManagerSubscription: Cancellable?
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager.getInstance()
    
    @Published var isReceiverConnected: Bool = false
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        watchConnectivityManagerSubscription = watchConnectivityManager.$isConnected.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                isReceiverConnected = watchConnectivityManager.isConnected
            }
        }
    }
    
    func startTransferringChannel() {
        send(dataType: .WatchSessionStart, data: Data())
    }
    
    func stopTransferringChannel() {
        send(dataType: .WatchSessionEnd, data: Data())
    }
    
    func send<T>(dataType: DataType, data: T) where T : Codable {
        do {
            watchConnectivityManager.sendAsString(
                data: try converter.encode(DataPacket(dataType: dataType, id: UUID(), data: try converter.encode(data))),
                replyHandler: nil,
                errorHandler:  { [weak self] error in
                    guard let self = self else { return }
                    
                    send(dataType: .WatchConnectivityError, data: Data())
                    
                    logger.log(message: "\(error)")
                }
            )
        } catch {
            logger.error(message: "\(error)")
        }
    }
}
