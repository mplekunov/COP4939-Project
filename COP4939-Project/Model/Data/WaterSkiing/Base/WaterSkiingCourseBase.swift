//
//  WaterSkiingCourseBase.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class WaterSkiingCourseBase<T> : Codable where T: Codable {
    let buoyPositions: Array<T>
    let wakeCrossPositions: Array<T>
    let entryGatePosition: T
    let exitGatePosition: T
    
    init(buoyPositions: Array<T>, wakeCrossPositions: Array<T>, entryGatePosition: T, exitGatePosition: T) {
        self.buoyPositions = buoyPositions
        self.wakeCrossPositions = wakeCrossPositions
        self.entryGatePosition = entryGatePosition
        self.exitGatePosition = exitGatePosition
    }
}
