//
//  CameraViewController.swift
//  CameraPlay
//
//  Created by Ola Loevholm on 25/04/2025.
//

import AVKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var faceCount: Int = 0
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
            print("Input outputAdded")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            print("Camera session started: \(self.session.isRunning)")

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
        
        print("Will process incoming frame")
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let results = request.results as? [VNFaceObservation] {
                let detected = results.count
                self.faceCount = detected
                print("Detected \(detected) face(s)")
            }
            if(error != nil) {
                print("Error \(String(describing: error))")
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        

    }
    
}
