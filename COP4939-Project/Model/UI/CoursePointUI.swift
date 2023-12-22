//
//  CoursepointUI.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import SwiftUI

struct CoursePointUI: Identifiable {
    let id: UUID
    let name: String
    let position: CGPoint
    let setColor: Color
    let unsetColor: Color
    
    init(id: UUID, name: String, position: CGPoint, setColor: Color, unsetColor: Color) {
        self.id = id
        self.name = name
        self.position = position
        self.setColor = setColor
        self.unsetColor = unsetColor
    }
    
    init(name: String, position: CGPoint, setColor: Color, unsetColor: Color) {
        self.id = UUID()
        self.name = name
        self.position = position
        self.setColor = setColor
        self.unsetColor = unsetColor
    }
}
