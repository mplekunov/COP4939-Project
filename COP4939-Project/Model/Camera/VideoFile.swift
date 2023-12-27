//
//  VideoFile.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/26/23.
//

import Foundation

struct VideoFile {
    let id: UUID
    let url: URL
    
    init(id: UUID, url: URL) {
        self.id = id
        self.url = url
    }
}
