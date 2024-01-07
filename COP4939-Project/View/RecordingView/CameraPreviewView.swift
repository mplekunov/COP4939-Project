import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    var captureSession: AVCaptureSession?
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        guard let session = captureSession else { return view }
        
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        return view
    }
    
    public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
    
    class VideoPreviewView: UIView {
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}
