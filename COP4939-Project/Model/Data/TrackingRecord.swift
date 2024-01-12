//
//  TrackingRecord.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class TrackingRecord : BaseTrackingRecord {
    let location: LocationRecord
    
    init(motion: MotionRecord, location: LocationRecord, timeOfRecrodingInSeconds: Double) {
        self.location = location
        super.init(motion: motion, timeOfRecordingInSeconds: timeOfRecrodingInSeconds)
    }
    
    enum CodingKeys: CodingKey {
        case motion
        case timeOfRecordingInSeconds
        case location
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.motion, forKey: .motion)
        try container.encode(self.timeOfRecordingInSeconds, forKey: .timeOfRecordingInSeconds)
        try container.encode(self.location, forKey: .location)
    }
 
    static func == (lhs: TrackingRecord, rhs: TrackingRecord) -> Bool {
        return lhs.motion == rhs.motion &&
        lhs.timeOfRecordingInSeconds == rhs.timeOfRecordingInSeconds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try container.decode(LocationRecord.self, forKey: .location)

        try super.init(from: decoder)
    }
}
