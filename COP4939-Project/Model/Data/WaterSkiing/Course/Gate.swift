//
//  Gate.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/15/23.
//

import Foundation

struct Gate {
    public let location: Coordinate
    public let maxSpeed: Measurement<UnitSpeed>
    public let maxRoll: Measurement<UnitAngle>
    public let maxPitch: Measurement<UnitAngle>
}