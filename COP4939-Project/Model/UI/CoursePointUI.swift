//
//  CoursepointUI.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import SwiftUI

struct CoursePointUI: Identifiable {
    let id = UUID()
    let name: String
    let position: CGPoint
    let setColor: Color
    let unsetColor: Color
}
