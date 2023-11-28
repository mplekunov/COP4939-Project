//
//  SessionInfo.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import Foundation

struct SessionInfo : Encodable, Decodable {
    let isStarting: Bool?
    let isEnding: Bool?
    
    init(isStarting: Bool) {
        self.isStarting = isStarting
        self.isEnding = nil
    }
    
    init(isEnding: Bool) {
        self.isEnding = isEnding
        self.isStarting = nil
    }
}
