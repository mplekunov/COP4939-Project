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
    
    @Published public private(set) var error: String?
    @Published public private(set) var isRecording: Bool?
    @Published public private(set) var videoFile: Video<URL>?
    
    private var creationDate: Date?
    
    private var outputFileURL: URL?
    
    private var id: UUID?
    
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
        
        CameraManager.instance.startRecording()
    }
    
    func stopRecording() {
        CameraManager.instance.stopRecording()
        
        guard let assetWriterInput = assetWriterInput else {
            error = AssetWriterError.AssetWriterInputIsUndefined.description
            return
        }
        
        assetWriterInput.markAsFinished()
        
        assetWriter?.finishWriting {
            self.logger.log(message: "Asset writer stopped recording")
            
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
                    
                    guard let id = self.id else {
                        self.error = "ID is not set for the video file."
                        return
                    }
                    
                    self.videoFile = Video(id: id, creationDate: creationDate.timeIntervalSince1970, fileLocation: outputFileURL)
                }
            }
        }
    }
    
    private func setupAssetWriter() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        creationDate = Date()
        id = UUID()
        videoFile = nil
        
        guard let id = id else {
            error = "ID cannot be empty"
            return
        }
        
        guard let documentsDirectory = documentsDirectory else {
            error = AssetWriterError.DirectoryIsUndefined.description
            return
        }
        
        let filename = "\(id.uuidString).mp4"
        outputFileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputFileURL!, fileType: .mp4)
            
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
            
            assetWriterInput.mediaTimeScale = CMTimeScale(bitPattern: 600)
            assetWriterInput.expectsMediaDataInRealTime = true
            
            if assetWriter.canAdd(assetWriterInput) {
                assetWriter.add(assetWriterInput)
            } else {
                error = AssetWriterError.CannotAddInput.description
                return
            }
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        } catch {
            self.error = AssetWriterError.CreateAssetWriter(error).description
            return
        }
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard isRecording == true else { return }
            
            guard let assetWriterInput = assetWriterInput else {
                error = AssetWriterError.AssetWriterInputIsUndefined.description
                return
            }
            
            guard let assetWriter = assetWriter else {
                error = AssetWriterError.AssetWriterIsUndefined.description
                return
            }
            
            guard let pixelBufferAdaptor = pixelBufferAdaptor else {
                error = AssetWriterError.PixelBufferAdaptorIsUndefined.description
                return
            }
            
            if assetWriter.status != .writing && assetWriter.status != .completed {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            }
            
            if let buffer = CMSampleBufferGetImageBuffer(sampleBuffer),
               assetWriterInput.isReadyForMoreMediaData,
               pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData,
               assetWriter.status == .writing {
                pixelBufferAdaptor.append(buffer, withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            }
        }
    }
}
