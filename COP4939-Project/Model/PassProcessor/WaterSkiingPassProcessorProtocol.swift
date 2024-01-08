//
//  WaterSkiingPassProcessorProtocol.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

protocol WaterSkiingPassProcessorProtocol {
    associatedtype R : Codable
    associatedtype V : Codable
    associatedtype P : Codable, Equatable
    associatedtype C : WaterSkiingCourseBase<P>
    
    func process(course: C, records: Array<R>, video: Video<V>) -> Pass<P, V>?
}
