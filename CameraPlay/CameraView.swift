//
//  CameraView.swift
//  CameraPlay
//
//  Created by Ola Loevholm on 25/04/2025.
//


import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var controller = CameraViewController()
    
    func makeUIViewController(context: Context) -> CameraViewController {
        controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
}
