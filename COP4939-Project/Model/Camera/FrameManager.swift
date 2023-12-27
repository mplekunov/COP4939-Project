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
    
    @Published public private(set) var current: CVPixelBuffer?
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    @Published public private(set) var videoFile: VideoFile?
    
    private var creationDate: Date?
    
    private var outputFileURL: URL?
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var cameraManagerErrorSubscriber: AnyCancellable?
    private var cameraManagerIsRecordingSubscriber: AnyCancellable?
    
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
                self.error = error?.description
            }
        }
        
        cameraManagerIsRecordingSubscriber = CameraManager.instance.$isRecording.sink { isRecording in
            DispatchQueue.main.async {
                self.isRecording = isRecording
            }
        }
    }
    
    func startRecording() {
        setupAssetWriter()
        videoFile = nil
        
        creationDate = Date()
        
        CameraManager.instance.startRecording()
    }
    
    func stopRecording() {
        CameraManager.instance.stopRecording()
        
        guard let assetWriterInput = assetWriterInput else {
            error = AssetWriterError.AssetWriterInputIsUndefined.description
            return
        }
        
        assetWriterInput.markAsFinished()
    }
    
    private func setupAssetWriter() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let documentsDirectory = documentsDirectory else {
            error = AssetWriterError.DirectoryIsUndefined.description
            return
        }
        
        let filename = "\(UUID().uuidString).mov"
        outputFileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputFileURL!, fileType: .mov)
            
            guard let assetWriter = assetWriter else {
                error = AssetWriterError.AssetWriterIsUndefined.description
                return
            }
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 1920,
                AVVideoHeightKey: 1080
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            
            guard let assetWriterInput = assetWriterInput else { 
                error = AssetWriterError.AssetWriterInputIsUndefined.description
                return
            }
            
            assetWriterInput.expectsMediaDataInRealTime = true
            
            if assetWriter.canAdd(assetWriterInput) {
                assetWriter.add(assetWriterInput)
            } else {
                error = AssetWriterError.CannotAddInput.description
                return
            }
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
            
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMTime.zero)
        } catch {
            self.error = AssetWriterError.CreateAssetWriter(error).description
        }
        
        assetWriter?.finishWriting {
            DispatchQueue.main.async {
                if let error = self.assetWriter?.error {
                    self.error = error.localizedDescription
                } else {
                    guard let outputFileURL = self.outputFileURL else {
                        self.error = "Output file url is not set for video file."
                        return
                    }
                    
                    guard let creationDate = self.creationDate else {
                        self.error = "Creation date is not set for video file."
                        return
                    }
                    
                    self.videoFile = VideoFile(id: UUID(), creationDate: creationDate.timeIntervalSince1970, url: outputFileURL)
                    
                }
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
        guard let assetWriterInput = assetWriterInput else { 
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                error = AssetWriterError.AssetWriterInputIsUndefined.description
            }
            
            return
        }
        guard let pixelBufferAdaptor = pixelBufferAdaptor else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                error = AssetWriterError.PixelBufferAdaptorIsUndefined.description
            }
            
            return
        }
        
        if let buffer = sampleBuffer.imageBuffer,
           assetWriterInput.isReadyForMoreMediaData,
           pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                pixelBufferAdaptor.append(buffer, withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                current = buffer
            }
        }
    }
}
