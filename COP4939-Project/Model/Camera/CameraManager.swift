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
    
    @Published public private(set) var error: CameraError?
    @Published public private(set) var isRecording = false
    @Published public private(set) var session: AVCaptureSession?
    
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
    }
    
    func startRecording() {
        guard !isRecording else {return}
        
        configure()
        
        session = AVCaptureSession()
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard let session = session else { return }
            
            configureCaptureSession()
            configureCaptureMode()
            
            session.startRunning()
            
            if error == nil && status == .Configured {
                DispatchQueue.main.async {
                    self.isRecording = true
                }
            }
        }
    }
    
    func stopRecording() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard let session = session else { return }
            
            session.stopRunning()
            
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
    }
    
    private func configure() {
        error = nil
        status = .Unconfigured
        
        checkPermissions()
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
        
        guard let session = session else { return }
        
        session.beginConfiguration()
        
        do {
            try addDevice(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back))
            try addDevice(AVCaptureDevice.default(for: .audio))
        } catch {
            set(error: .CreateCaptureInput(error))
            status = .Failed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    private func configureCaptureMode() {
        guard let session = session else { return }
        
        logger.log(message: "Trying to configure capture mode")
        
        if session.canAddOutput(videoOutput) {
            session.beginConfiguration()
            
            session.addOutput(videoOutput)
            session.sessionPreset = .hd1920x1080
            
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
                
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = false
                }
                
                connection.videoOrientation = .portrait
            }
        } else {
            set(error: .CannotAddOutput)
            status = .Failed
            session.commitConfiguration()
            return
        }
        
        status = .Configured
        session.commitConfiguration()
    }
    
    private func addDevice(_ device: AVCaptureDevice?) throws {
        guard let session = session else { return }
        
        guard let device = device else {
            set(error: .CameraUnavailable)
            status = .Failed
            return
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            set(error: .CannotAddInput)
            status = .Failed
            return
        }
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
