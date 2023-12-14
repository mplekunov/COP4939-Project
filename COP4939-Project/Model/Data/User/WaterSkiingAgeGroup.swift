//
//  AgeGroup.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/12/23.
//

import Foundation

enum WaterSkiingAgeGroup {
    case Group_1
    case Group_2
    case Group_3
    case Group_4
    case Group_5
    case Group_6
    case Group_7
    case Group_8
    case Group_9
    case Group_10
    case Group_11
    case Group_12
    case Group_13
    
    func getAgeGroup(age: Int) -> WaterSkiingAgeGroup? {
        switch age {
        case 1...9: return .Group_1
        case 1...12: return .Group_2
        case 13...16: return .Group_3
        case 17...24: return .Group_4
        case 25...34: return .Group_5
        case 35...44: return .Group_6
        case 45...52: return .Group_7
        case 53...59: return .Group_8
        case 60...64: return .Group_9
        case 65...69: return .Group_10
        case 70...74: return .Group_11
        case 75...79: return .Group_12
        case 80...Int.max: return .Group_13
        default: return nil
        }
    }
    
    func getAsString(ageGroup: WaterSkiingAgeGroup) -> String {
        switch ageGroup {
        case .Group_1: return "Boys and Girls 1"
        case .Group_2: return "Boys and Girls 2"
        case .Group_3: return "Boys and Girls 3"
        case .Group_4: return "Men and Women 1"
        case .Group_5: return "Men and Women 2"
        case .Group_6: return "Men and Women 3"
        case .Group_7: return "Men and Women 4"
        case .Group_8: return "Men and Women 5"
        case .Group_9: return "Men and Women 6"
        case .Group_10: return "Men and Women 7"
        case .Group_11: return "Men and Women 8"
        case .Group_12: return "Men and Women 9"
        case .Group_13: return "Men and Women 10"
        }
    }
}
