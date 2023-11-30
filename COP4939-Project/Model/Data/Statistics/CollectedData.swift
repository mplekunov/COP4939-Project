//
//  CollectedData.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/23/23.
//

import Foundation

struct CollectedData : Codable, Equatable {
    let locationData: Location
    let motionData: MotionData
    let timeStamp: Double = Date().timeIntervalSince1970
    
    init(sessionStart: Bool) {
        self.locationData = Location()
        self.motionData = MotionData()
    }

    init(sessionEnd: Bool) {
        self.locationData = Location()
        self.motionData = MotionData()
    }
    
    init(locationData: Location, motionData: MotionData) {
        self.locationData = locationData
        self.motionData = motionData
    }
    
    init() {
        self.locationData = Location()
        self.motionData = MotionData()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.locationData = try container.decode(Location.self, forKey: .locationData)
        self.motionData = try container.decode(MotionData.self, forKey: .motionData)
    }
    
    enum CodingKeys: CodingKey {
        case locationData
        case motionData
        case timeStamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.locationData, forKey: .locationData)
        try container.encode(self.motionData, forKey: .motionData)
        try container.encode(self.timeStamp, forKey: .timeStamp)
    }
 
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.locationData == rhs.locationData &&
        lhs.motionData == rhs.motionData
    }
}
