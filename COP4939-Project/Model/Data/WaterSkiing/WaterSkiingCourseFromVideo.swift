//
//  WaterSkiingCourseFromVideo.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class WaterSkiingCourseFromVideo : WaterSkiingCourseBase<Double> {
    let totalScore: Int
    
    init (
        totalScore: Int,
        buoyPositions: Array<Double>,
        wakeCrossPositions: Array<Double>,
        entryGatePosition: Double,
        exitGatePosition: Double
    ) {
        self.totalScore = totalScore
        
        super.init(
            buoyPositions: buoyPositions,
            wakeCrossPositions: wakeCrossPositions,
            entryGatePosition: entryGatePosition,
            exitGatePosition: exitGatePosition
        )
    }
    
    enum CodingKeys: CodingKey {
        case totalScore
        case buoyPositions
        case wakeCrossPositions
        case entryGatePosition
        case exitGatePosition
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.buoyPositions, forKey: .buoyPositions)
        try container.encode(self.totalScore, forKey: .totalScore)
        try container.encode(self.exitGatePosition, forKey: .exitGatePosition)
        try container.encode(self.wakeCrossPositions, forKey: .wakeCrossPositions)
        try container.encode(self.entryGatePosition, forKey: .entryGatePosition)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalScore = try container.decode(Int.self, forKey: .totalScore)
        
        try super.init(from: decoder)
    }
}
