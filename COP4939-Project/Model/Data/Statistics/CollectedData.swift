//
//  CollectedData.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct CollectedData : Encodable, Decodable {
    let locationData: Location
    let motionData: MotionData
    let timeStamp: Double = Date().timeIntervalSince1970
    let sessionStart: Bool?
    let sessionEnd: Bool?
    
    init(sessionStart: Bool) {
        self.locationData = Location()
        self.motionData = MotionData()
        self.sessionStart = sessionStart
        self.sessionEnd = nil
    }

    init(sessionEnd: Bool) {
        self.locationData = Location()
        self.motionData = MotionData()
        self.sessionStart = nil
        self.sessionEnd = sessionEnd
    }
    
    init(locationData: Location, motionData: MotionData) {
        self.locationData = locationData
        self.motionData = motionData
        self.sessionStart = nil
        self.sessionEnd = nil
    }
    
    init() {
        self.locationData = Location()
        self.motionData = MotionData()
        self.sessionStart = nil
        self.sessionEnd = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.locationData = try container.decode(Location.self, forKey: .locationData)
        self.motionData = try container.decode(MotionData.self, forKey: .motionData)
        self.sessionStart = try container.decodeIfPresent(Bool.self, forKey: .sessionStart)
        self.sessionEnd = try container.decodeIfPresent(Bool.self, forKey: .sessionEnd)
    }
    
    enum CodingKeys: CodingKey {
        case locationData
        case motionData
        case timeStamp
        case sessionStart
        case sessionEnd
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.locationData, forKey: .locationData)
        try container.encode(self.motionData, forKey: .motionData)
        try container.encode(self.timeStamp, forKey: .timeStamp)
        try container.encodeIfPresent(self.sessionStart, forKey: .sessionStart)
        try container.encodeIfPresent(self.sessionEnd, forKey: .sessionEnd)
    }
}
