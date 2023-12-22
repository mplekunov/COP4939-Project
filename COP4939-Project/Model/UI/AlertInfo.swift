//
//  AlertInfo.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/22/23.
//

import Foundation

struct AlertInfo : Identifiable {
    enum AlertType {
        case Camera
        case DataSender
        case LocationManager
        case WaterSkiingCourse
    }
    
    let id: AlertType
    let title: String
    let message: String
}
