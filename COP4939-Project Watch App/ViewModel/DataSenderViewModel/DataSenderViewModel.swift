//
//  DataSenderViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import Combine

class DataSenderViewModel : ObservableObject {
    private let MAX_RETRY_ATTEMPTS: Int = 3

    private let logger: LoggerService

    private let converter: JSONConverter = JSONConverter()
    
    private var watchConnectivityManagerSubscription: Cancellable?
    private var watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
    
    private var cache: DataCache<UUID, DataPacket> = DataCache()
    
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
    
    func send<T>(dataType: DataType, data: T) where T : Encodable {
        do {
            let dataPacket = try encodeToDataPacket(dataType: dataType, data: data)
            
            cache.addValueToCache(key: dataPacket.id, value: dataPacket)
            
            send(data: dataPacket)
        } catch {
            logger.error(message: "Data could not be encoded correctly")
        }
    }
    
    private func send(data: DataPacket) {
        watchConnectivityManager.send(
            data: data,
            replyHandler: { [weak self] reply in
                guard let self = self else { return }
                
                logger.log(message: "Reply has been received.")
                
                do {
                    let dataPacket = try converter.decode(DataPacket.self, from: reply)
                    
                    if dataPacket.dataType == .DataDeliveryInformation {
                        let deliveryInformation = try converter.decode(DeliveryInformation.self, from: dataPacket.data)
                        
                        if !deliveryInformation.isDelivered {
                            retryMessageSendingOnFailure(messageID: deliveryInformation.id)
                        } else {
                            cache.removeValueFromCache(key: deliveryInformation.id)
                            logger.log(message: "Message has been delivered and cache has been cleared.")
                        }
                    } else {
                        logger.error(message: "DataType has not been recognized in reply.")
                    }
                } catch {
                    logger.error(message: "\(error)")
                    retryMessageSendingOnFailure(messageID: data.id)
                    logger.log(message: "Redelivering message...")
                }
            },
            errorHandler: { [weak self] error in
                guard let self = self else { return }
                
                logger.log(message: "\(error)")
            }
        )
    }
    
    private func retryMessageSendingOnFailure(messageID: UUID) {
        if let counter = cache.getRetryCounter(key: messageID),
           let data = cache.getCache(key: messageID) {
            
            if counter < MAX_RETRY_ATTEMPTS {
                cache.updateRetryCounter(key: messageID, counter: counter + 1)
                send(data: data)
            } else {
                logger.error(message: "Message couldn't be delivered. Redelivery attempts have been exceeded maximum allowable value of \(MAX_RETRY_ATTEMPTS).")
            }
        } else {
            logger.error(message: "There is no value with such messageID being cached. ~ \(messageID)")
        }
    }
    
    private func encodeToDataPacket<T>(dataType: DataType, data: T) throws -> DataPacket where T : Encodable {
        do {
            let dataEncoded = try converter.encode(data)
            return DataPacket(dataType: dataType, id: UUID(), data: dataEncoded)
        } catch {
            throw JsonError.EncodingError
        }
    }
}
