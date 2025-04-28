//
//  ContentView.swift
//  CameraPlay
//
//  Created by Ola Loevholm on 25/04/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var controller = CameraViewController()

    var body: some View {
        ZStack(alignment: .top) {
            CameraView(controller: controller)
            GeometryReader { geometry in
                ForEach(0..<controller.faceRects.count, id: \.self) { index in
                    let rect = controller.faceRects[index]
                    let convertedRect = controller.convertFaceRect(rect)
                    Rectangle()
                        .stroke(Color.red, lineWidth: 4)
                        .frame(width: convertedRect.width, height: convertedRect.height)
                        .position(x: convertedRect.midX, y: convertedRect.midY)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: convertedRect)
                }
            }
            VStack {
                Spacer()
                Text("Faces detected: \(controller.faceCount)")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    

}

#Preview {
    ContentView()
}
