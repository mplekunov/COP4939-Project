//
//  CollectedData.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/19/23.
//

import Foundation

struct BaseTrackingRecord : Codable, Equatable {
    let motion: MotionRecord
    let timeOfRecrodingInSeconds: Double
    
    init(motion: MotionRecord, timeOfRecordingInSeconds: Double) {
        self.motion = motion
        self.timeOfRecrodingInSeconds = timeOfRecordingInSeconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.motion = try container.decode(MotionRecord.self, forKey: .motion)
        self.timeOfRecrodingInSeconds = try container.decode(Double.self, forKey: .timeOfRecordingInSeconds)
    }
    
    enum CodingKeys: CodingKey {
        case motion
        case timeOfRecordingInSeconds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.motion, forKey: .motion)
        try container.encode(self.timeOfRecrodingInSeconds, forKey: .timeOfRecordingInSeconds)
    }
 
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.motion == rhs.motion &&
        lhs.timeOfRecrodingInSeconds == rhs.timeOfRecrodingInSeconds
    }
}
