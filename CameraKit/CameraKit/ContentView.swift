//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI

struct ContentView: View {
    
    var viewModel: CameraManager = CameraManager()
    var body: some View {
        VStack {
            switch viewModel.state {
            case .unknown:
                Text("Loading")
            case .permissionDenied:
                Text("Permission Denied")
            case .active:
                CameraPreview(cameraOutput: viewModel.cameraInputManger.output)
            case .paused:
                Text("Paused")
                
            }
        }.onAppear(perform: {
            Task {
                await viewModel.setup()
            }
        })
        .padding()
    }
}

#Preview {
    ContentView()
}


struct CameraPreview: UIViewRepresentable {
    let cameraOutput: any CameraOutputProtocol

    func makeUIView(context: Context) -> UIView {
        return  cameraOutput.previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}
