//
//  CameraModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/21/23.
//

import Foundation
import AVFoundation

class CameraManager: ObservableObject {
    private let logger: LoggerService
    
    @Published var error: CameraError?
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label:"com.CameraManager")
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var status = Status.Unconfigured
    
    enum Status {
        case Unconfigured
        case Configured
        case Unauthorized
        case Failed
    }
    
    static let instance = CameraManager()
    
    private init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        configure()
    }
    
    private func configure() {
        checkPermissions()
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            configureCaptureSession()
            session.startRunning()
        }
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.error = error
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .Unauthorized
                    self.set(error: .DeniedAuthorization)
                }
                
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .Unauthorized
            set(error: .RestrictedAuthorization)
        case .denied:
            status = .Unauthorized
            set(error: .DeniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .Unauthorized
            set(error: .UnknownAuthorization)
        }
    }
    
    private func configureCaptureSession() {
        guard status == .Unconfigured else {
            return
        }
        
        session.beginConfiguration()
        
        defer {
            session.commitConfiguration()
        }
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let camera = device else {
            set(error: .CameraUnavailable)
            status = .Failed
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                set(error: .CannotAddInput)
                status = .Failed
                return
            }
        } catch {
            set(error: .CreateCaptureInput(error))
            status = .Failed
            return
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            set(error: .CannotAddOutput)
            status = .Failed
            return
        }
        
        status = .Configured
    }
    
    func set(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
}
