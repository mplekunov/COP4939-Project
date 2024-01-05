//
//  WaterSkiingCourseViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/19/23.
//

import Foundation

class WaterSkiingCourseViewModel : ObservableObject {
    @Published public private(set) var course: WaterSkiingCourse?
    
    private let logger: LoggerService
    private let fileManager = FileManager.default
    
    private let fileName: String = "Course.txt"
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        if let path = getURL()?.path(), fileManager.fileExists(atPath: path) {
            logger.log(message: "file exists")
            do {
                try downloadFromDocuments()
            } catch {
                logger.log(message: "\(error)")
            }
        }
    }
    
    func setCourse(_ course: WaterSkiingCourse) {
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
            fileManager.createFile(atPath: path, contents: dataToSave, attributes: nil)
        }
    }
    
    private func downloadFromDocuments() throws {
        if let url = getURL() {
            let data = try Data(contentsOf: url)
            course = try JSONConverter().decode(WaterSkiingCourse.self, from: data)
        }
    }
}
