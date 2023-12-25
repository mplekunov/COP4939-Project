//
//  VideoFileManager.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/25/23.
//

import Foundation

class DatabaseManager {
    func getURL(id: UUID) -> URL {
        return Bundle.main.url(forResource: "video", withExtension: "mp4")!
    }
}
