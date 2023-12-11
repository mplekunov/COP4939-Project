//
//  Fin.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Fin {
    let length: Measurement<UnitLength>
    let depth: Measurement<UnitLength>
    let dft: Measurement<UnitLength>
    let wingAngle: Measurement<UnitAngle>
    let bladeThickness: Measurement<UnitLength>
    
    init(
        length: Measurement<UnitLength>,
        depth: Measurement<UnitLength>,
        dft: Measurement<UnitLength>,
        wingAngle: Measurement<UnitAngle>,
        bladeThickness: Measurement<UnitLength>
    ) {
        self.length = length
        self.depth = depth
        self.dft = dft
        self.wingAngle = wingAngle
        self.bladeThickness = bladeThickness
    }
}
