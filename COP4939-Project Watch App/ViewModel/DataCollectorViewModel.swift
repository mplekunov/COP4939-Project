//
//  DataCollectorViewModel.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation
import Combine

class DataCollectorViewModel : ObservableObject {
    private var deviceMotionSensorModel: DeviceMotionSensorViewModel
    private var deviceLocationSensorModel: DeviceLocationSensorViewModel
    
    private var locationDataSubscription: AnyCancellable?
    private var motionDataSubscription: AnyCancellable?
    private var combinedDataSubscription: AnyCancellable?
    
    @Published var locationData: Array<Location> = Array()
    @Published var motionData: Array<MotionData> = Array()
    @Published var collectedData: Array<CollectedData> = Array()
    
    init(
        deviceMotionSensorModel: DeviceMotionSensorViewModel,
        deviceLocationSensorModel: DeviceLocationSensorViewModel
    ) {
        self.deviceMotionSensorModel = deviceMotionSensorModel
        self.deviceLocationSensorModel = deviceLocationSensorModel
        
        self.locationDataSubscription = deviceLocationSensorModel.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            self.locationData = deviceLocationSensorModel.data
        }
        
        self.motionDataSubscription = deviceMotionSensorModel.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            self.motionData = deviceMotionSensorModel.data
        }
        
        self.combinedDataSubscription = deviceMotionSensorModel.objectWillChange
            .combineLatest(deviceLocationSensorModel.objectWillChange) { _,_  in
                let locationData = deviceLocationSensorModel.data.last ?? Location()
                let motionData = deviceMotionSensorModel.data.last ?? MotionData()
                
                return CollectedData(locationData: locationData, motionData: motionData)
            }
            .sink(receiveValue: {[weak self] data in
                guard let self = self else { return }
                self.collectedData.append(data)
            })
    }
    
    func startDataCollection() -> Bool {
        if deviceLocationSensorModel.startRecording() {
            deviceMotionSensorModel.startRecording()
            return true
        }
        
        return false        
    }
    
    func stopDataCollection() {
        deviceMotionSensorModel.stopRecording()
        deviceLocationSensorModel.stopRecording()
    }
}
