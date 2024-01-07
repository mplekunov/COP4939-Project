//
//  VideoFile.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/26/23.
//

import Foundation

struct Video<T> : Codable where T : Codable {
    let id: UUID
    let creationDate: Double
    let fileLocation: T
    
    init(id: UUID, creationDate: Double, fileLocation: T) {
        self.id = id
        self.fileLocation = fileLocation
        self.creationDate = creationDate
    }
}
