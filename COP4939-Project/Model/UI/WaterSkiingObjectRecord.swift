//
//  WaterSkiingVideMomentDetails.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/26/23.
//

import Foundation

struct WaterSkiingObjectRecord : Identifiable, Equatable {
    let id: UUID
    let objectName: String
    let objectIndex: Int
    let objectType: WaterSkiingObjectType
    let videoTimeStamp: Double
    
    init(id: UUID, objectName: String, objectIndex: Int, objectType: WaterSkiingObjectType, videoTimeStamp: Double) {
        self.id = id
        self.objectName = objectName
        self.objectIndex = objectIndex
        self.objectType = objectType
        self.videoTimeStamp = videoTimeStamp
    }
    
    init(objectName: String, objectIndex: Int, objectType: WaterSkiingObjectType, videoTimeStamp: Double) {
        self.id = UUID()
        self.objectName = objectName
        self.objectIndex = objectIndex
        self.objectType = objectType
        self.videoTimeStamp = videoTimeStamp
    }
}
