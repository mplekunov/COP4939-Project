//
//  ChartData.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 11/30/23.
//

import Foundation

struct ChartData : Identifiable {
    var id: UUID = UUID()
    var date: Date
    var data: Double
    
    init(date: Date, data: Double) {
        self.data = data
        self.date = date
    }
}
