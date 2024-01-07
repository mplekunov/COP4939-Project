//
//  CollectedData.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

class WatchTrackingRecord : Codable, Equatable {
    let motion: MotionRecord
    let timeOfRecordingInSeconds: Double
    
    init(motion: MotionRecord, timeOfRecordingInSeconds: Double) {
        self.motion = motion
        self.timeOfRecordingInSeconds = timeOfRecordingInSeconds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.motion = try container.decode(MotionRecord.self, forKey: .motion)
        self.timeOfRecordingInSeconds = try container.decode(Double.self, forKey: .timeOfRecordingInSeconds)
    }
    
    enum CodingKeys: CodingKey {
        case motion
        case timeOfRecordingInSeconds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.motion, forKey: .motion)
        try container.encode(self.timeOfRecordingInSeconds, forKey: .timeOfRecordingInSeconds)
    }
 
    static func == (lhs: WatchTrackingRecord, rhs: WatchTrackingRecord) -> Bool {
        return lhs.motion == rhs.motion &&
        lhs.timeOfRecordingInSeconds == rhs.timeOfRecordingInSeconds
    }
}
