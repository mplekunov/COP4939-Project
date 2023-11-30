//
//  LoggerService.swift
//  COP4939-Project Watch App
//
//  Created by Mikhail Plekunov on 11/28/23.
//

import Foundation

struct LoggerService {
    private var logSource: String
    
    init(logSource: String) {
        self.logSource = logSource
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: Date())
    }
    
    func log(message: String) {
        print("[\(getCurrentDate())] [\(logSource)]: \(message)")
    }
    
    func error(message: String) {
        print("[\(getCurrentDate())] [\(logSource)] ERROR: \(message)]")
    }
}
