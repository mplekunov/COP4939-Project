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
    
    private var watchConnectivityManagerSubscription: Cancellable?
    
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    @Published var isReceiverConnected: Bool = false
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        watchConnectivityManagerSubscription = watchConnectivityManager.$isConnected.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isReceiverConnected = self.watchConnectivityManager.isConnected
            }
        }
    }
    
    func startTransferringChannel() {
        send(dataType: .WatchSessionStart, data: Data())
    }
    
    func stopTransferringChannel() {
        send(dataType: .WatchSessionEnd, data: Data())
    }

    func send<T>(dataType: DataType, data: T) where T : Encodable {
        do {
            let data = try encodeToData(dataType: dataType, data: data)
            
            watchConnectivityManager.send(
                data: data,
                replyHandler: nil,
                errorHandler: { error in
                    self.logger.log(message: "\(error)")
                }
            )
        } catch {
            logger.error(message: "Data could not be encoded correctly")
        }
    }
    
    private func encodeToData<T>(dataType: DataType, data: T) throws -> Data where T : Encodable {
        let encoder = JSONEncoder()
        
        do {
            let dataEncoded = try encoder.encode(data)
            return try encoder.encode(DataPacket(dataType: dataType, data: dataEncoded))
        } catch {
            throw JsonError.EncodingError
        }
    }
}
