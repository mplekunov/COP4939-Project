//
//  CollectedData.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation

struct TrackingRecord : Codable, Equatable {
    let location: LocationRecord
    let motion: MotionRecord
    let timeOfRecrodingInSeconds: Double
    
    init(location: LocationRecord, motion: MotionRecord, timeOfRecordingInSeconds: Double) {
        self.location = location
        self.motion = motion
        self.timeOfRecrodingInSeconds = timeOfRecordingInSeconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try container.decode(LocationRecord.self, forKey: .location)
        self.motion = try container.decode(MotionRecord.self, forKey: .motion)
        self.timeOfRecrodingInSeconds = try container.decode(Double.self, forKey: .timeOfRecordingInSeconds)
    }
    
    enum CodingKeys: CodingKey {
        case location
        case motion
        case timeOfRecordingInSeconds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.location, forKey: .location)
        try container.encode(self.motion, forKey: .motion)
        try container.encode(self.timeOfRecrodingInSeconds, forKey: .timeOfRecordingInSeconds)
    }
 
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.location == rhs.location &&
        lhs.motion == rhs.motion
    }
}
