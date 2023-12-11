//
//  ChartData.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 11/30/23.
//

import Foundation

struct ChartData<U> : Identifiable where U : Dimension {
    var id: UUID = UUID()
    var date: Date
    var data: Measurement<U>
    
    init(date: Date, data: Measurement<U>) {
        self.data = data
        self.date = date
    }
}
