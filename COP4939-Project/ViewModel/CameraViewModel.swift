//
//  CameraViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/21/23.
//

import Foundation
import CoreImage
import CoreGraphics
import Combine

class CameraViewModel: ObservableObject {
    @Published public private(set) var frame: CGImage?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    
    private let frameManager = FrameManager.instance
    
    init() {
        setupSubscriptions()
    }
    
    func startRecording() {
        frameManager.startRecording()
    }
    
    func stopRecording() {
        frameManager.stopRecording()
    }
    
    func setupSubscriptions() {
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                guard let buffer = buffer else { return nil }
                
                let ciContext = CIContext()
                let ciImage = CIImage(cvImageBuffer: buffer )
                return ciContext.createCGImage(ciImage, from: ciImage.extent)
            }
            .assign(to: &$frame)
        
        frameManager.$error
            .receive(on: RunLoop.main)
            .assign(to: &$error)
        
        frameManager.$isRecording
            .receive(on: RunLoop.main)
            .assign(to: &$isRecording)
    }
}
