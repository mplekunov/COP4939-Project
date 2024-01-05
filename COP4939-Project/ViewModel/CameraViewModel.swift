//
//  CameraViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/21/23.
//

import Foundation
import Combine
import VideoToolbox

class CameraViewModel: ObservableObject {
    @Published public private(set) var frame: CGImage?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    @Published public private(set) var videoFile: VideoFile?
    
    private let frameManager = FrameManager.instance
    
    init() {
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                guard let buffer = buffer else { return nil }
                
                var imageOut: CGImage?
                VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &imageOut)
                
                return imageOut
            }
            .assign(to: &$frame)
        
        frameManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
        
        frameManager.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecording)
        
        frameManager.$videoFile
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoFile)
    }
    
    func startRecording() {
        frameManager.startRecording()
    }
    
    func stopRecording() {
        frameManager.stopRecording()
    }
}
