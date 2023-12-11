//
//  Ski.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Ski {
    let brand: String
    let style: String
    let length: Measurement<UnitLength>
    let bindingType: String
    
    init(brand: String, style: String, length: Measurement<UnitLength>, bindingType: String) {
        self.brand = brand
        self.style = style
        self.length = length
        self.bindingType = bindingType
    }
}
