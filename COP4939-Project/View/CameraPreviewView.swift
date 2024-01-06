import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable { // for attaching AVCaptureVideoPreviewLayer to SwiftUI View
    
    let captureSession: AVCaptureSession?
    
    // creates and configures a UIKit-based video preview view
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        guard let session = captureSession else { return view }
        
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        return view
    }
    
    // updates the video preview view
    public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
    
    // UIKit-based view for displaying the camera preview
    class VideoPreviewView: UIView {
        
        // specifies the layer class used
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        // retrieves the AVCaptureVideoPreviewLayer for configuration
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}
