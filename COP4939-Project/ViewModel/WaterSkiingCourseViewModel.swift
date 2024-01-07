//
//  WaterSkiingCourseFromCoordinatesViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

class WaterSkiingCourseViewModel<T> : ObservableObject where T : Codable {
    @Published public private(set) var course: T?
    
    private let logger: LoggerService
    private let fileManager = FileManager.default
    
    private let fileName: String
    
    init(courseFileName: String) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        fileName = courseFileName
        
        if let path = getURL()?.path(), fileManager.fileExists(atPath: path) {
            logger.log(message: "Water Course file exists")
            do {
                try downloadFromDocuments()
            } catch {
                logger.log(message: "\(error)")
            }
        }
    }
    
    func setCourse(_ course: T) {
        self.course = course
        
        do {
            try saveToDocuments()
        } catch {
            logger.log(message: "\(error)")
        }
    }
    
    private func getURL() -> URL? {
        if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent(fileName)
        }
        
        return nil
    }
    
    private func saveToDocuments() throws {
        let dataToSave = try JSONConverter().encode(course)

        if let path = getURL()?.path() {
            fileManager.createFile(atPath: path, contents: dataToSave)
        }
    }
    
    private func downloadFromDocuments() throws {
        if let url = getURL() {
            let data = try Data(contentsOf: url)
            course = try JSONConverter().decode(T.self, from: data)
        }
    }
}
