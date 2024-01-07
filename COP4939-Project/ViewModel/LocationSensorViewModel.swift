//
//  LocationSensorViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import Combine

class LocationSensorViewModel : ObservableObject {
    private let logger: LoggerService
    
    @Published public private(set) var lastLocation: LocationRecord?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    func startRecording() {}
    
    func stopRecording() {}
}
