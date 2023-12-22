//
//  DataSenderViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/19/23.
//

import Foundation
import Combine

class DataSenderViewModel : ObservableObject {
    private let logger: LoggerService
    
    private var converter: JSONConverter = JSONConverter()
    
    private var watchConnectivityManagerSubscription: Cancellable?
    private let watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager.instance
    
    @Published var error: WatchConnectivityError?
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        watchConnectivityManagerSubscription = watchConnectivityManager.$error.sink { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                error = watchConnectivityManager.error
            }
        }
    }
    
    func send<T>(dataType: DataType, data: T) where T : Codable {
        do {
            watchConnectivityManager.sendAsString(
                data: try converter.encode(DataPacket(dataType: dataType, id: UUID(), data: try converter.encode(data))),
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
}
