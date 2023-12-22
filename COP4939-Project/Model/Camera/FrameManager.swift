//
//  FrameManager.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/21/23.
//

import Foundation
import AVFoundation
import Combine

class FrameManager: NSObject, ObservableObject {
    private let logger: LoggerService
    static let instance = FrameManager()
    
    @Published var current: CVPixelBuffer?
    @Published var error: CameraError?
    
    private var cameraManagerErrorSubscriber: AnyCancellable?
    
    let videoOutputQueue = DispatchQueue(
        label: "com.FrameManager",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    private override init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        super.init()
        
        CameraManager.instance.set(self, queue: videoOutputQueue)
        
        cameraManagerErrorSubscriber = CameraManager.instance.$error.sink { error in
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        logger.log(message: "?")
        
        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                current = buffer
            }
        }
    }
}
