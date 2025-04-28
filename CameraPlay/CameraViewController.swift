//
//  CameraViewController.swift
//  CameraPlay
//
//  Created by Ola Loevholm on 25/04/2025.
//

import AVKit
import AVFoundation
import Vision
import OSLog


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var faceCount: Int = 0
    @Published var faceRects: [CGRect] = []
    private var isUsingFrontCamera = false

    var faceLayers: [CAShapeLayer] = []
    
    private var lastProcessTime = Date()
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "CameraQueue")
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        
        session.addInput(input)
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            session.addOutput(videoOutput)
            os_log(.info, "Input outputAdded")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            os_log(.debug, "Camera session started: \(self.session.isRunning)")

        }
        
        

                
        }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let processInterval: TimeInterval = 1 // seconds between detection runs (~3 fps)
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let now = Date()
        if now.timeIntervalSince(lastProcessTime) < processInterval {
            return // Skip this frame
        }
        lastProcessTime = now
        
        os_log(.debug, "Will process incoming frame")
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let results = request.results as? [VNFaceObservation] {
                let detected = results.count
                DispatchQueue.main.async {
                    self.faceRects.removeAll()
                }
                for result in results {
                    os_log(.debug, "Face at %@", result.boundingBox.debugDescription)
                    DispatchQueue.main.async {
                        self.faceRects.append(result.boundingBox)
                    }
                }
                os_log(.debug, "Detected %d face(s)", detected)
                
                DispatchQueue.main.async {
                    self.faceCount = detected
                }
                
            }
            if(error != nil) {
                os_log(.error, "Error occurred while processing face detection request: %@", String(describing: error))
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        

    }
    
    func convertFaceRect(_ boundingBox: CGRect) -> CGRect {
        return previewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)
    }
    
}
