//
//  Double.swift
//  WatchApp Watch App
//
//  Created by Mikhail Plekunov on 11/18/23.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
