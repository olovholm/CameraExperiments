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
